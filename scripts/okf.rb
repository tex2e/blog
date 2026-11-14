#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "date"
require "time"
require "json"
require "optparse"
require "fileutils"

# OKF v0.2 validation, staleness reporting, index synchronization, and changelog CLI for this Jekyll blog.
module OKF
  ROOT = File.expand_path("..", __dir__)
  POSTS_DIR = File.join(ROOT, "_posts")
  ROOT_INDEX = File.join(ROOT, "index.md")
  ROOT_LOG = File.join(ROOT, "log.md")

  ALLOWED_TYPES = %w[
    How-To
    Concept
    Reference
    Troubleshooting
    Essay
    Book\ Chapter
    Template
  ].freeze
  ALLOWED_STATUSES = %w[draft stable deprecated].freeze
  ISO_UTC_OFFSET_RE = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})\z/
  ACTOR_RE = /\A(?:human:[A-Za-z0-9_.@-]+|process:[A-Za-z0-9_.@-]+|[A-Za-z0-9_.-]+\/[A-Za-z0-9_.:-]+)\z/
  INDEX_START_MARKER = "<!-- OKF:INDEX:START -->"
  INDEX_END_MARKER = "<!-- OKF:INDEX:END -->"

  module_function

  def parse_frontmatter(path)
    raw = File.read(path, encoding: "UTF-8")
    m = raw.match(/\A---\s*\n(.*?)\n---(?:\s*\n(.*))?\z/m)
    return [nil, "", raw, "Missing YAML frontmatter block"] unless m

    fm_str = m[1]
    body = m[2].to_s
    data = YAML.safe_load(fm_str, permitted_classes: [Date, Time], aliases: false) || {}
    return [nil, fm_str, body, "Frontmatter must be a YAML mapping"] unless data.is_a?(Hash)

    [data, fm_str, body, nil]
  rescue Psych::SyntaxError => e
    [nil, "", raw.to_s, "YAML syntax error: #{e.message}"]
  end

  def valid_iso_offset_timestamp?(val, raw_fm = nil, key_hint = nil)
    case val
    when String
      return false unless val.match?(ISO_UTC_OFFSET_RE)
      Time.iso8601(val)
      true
    when Time
      # Ensure the source scalar did not omit T or explicit UTC offset (Psych parses bare local times as Time).
      if raw_fm && key_hint
        scalar_matches = raw_fm.scan(/^\s*(?:-\s*)?#{Regexp.escape(key_hint)}:\s*(.+)$/).flatten
        return true if scalar_matches.any? { |s| s.strip.gsub(/\A['"]|['"]\z/, "").match?(ISO_UTC_OFFSET_RE) }
        return false
      end
      true
    else
      false
    end
  rescue ArgumentError
    false
  end

  def to_utc_time(val)
    case val
    when Time then val.utc
    when String then Time.iso8601(val).utc
    end
  rescue ArgumentError
    nil
  end

  def post_files
    Dir.glob(File.join(POSTS_DIR, "**", "*.md"))
       .reject { |p| %w[index.md log.md].include?(File.basename(p)) }
       .sort
  end

  def post_directories
    dirs = {}
    post_files.each do |file|
      dir = File.dirname(file)
      while dir.start_with?(POSTS_DIR)
        dirs[dir] = true
        break if dir == POSTS_DIR
        dir = File.dirname(dir)
      end
    end
    dirs.keys.sort
  end

  def validate(strict: false, json_out: false)
    errors = []
    warnings = []
    posts = post_files

    validate_root_files(errors, warnings)
    validate_directories(errors, warnings)

    posts.each do |abs_path|
      rel_path = abs_path.sub("#{ROOT}/", "")
      data, fm_str, _body, parse_err = parse_frontmatter(abs_path)
      if parse_err
        errors << { file: rel_path, message: parse_err }
        next
      end

      validate_post_frontmatter(rel_path, data, fm_str, strict, errors, warnings)
    end

    if json_out
      puts JSON.pretty_generate(
        ok: errors.empty? && (!strict || warnings.empty?),
        posts_checked: posts.size,
        error_count: errors.size,
        warning_count: warnings.size,
        errors: errors,
        warnings: warnings
      )
    else
      puts "Checked #{posts.size} posts: #{errors.size} errors, #{warnings.size} warnings"
      errors.first(50).each { |e| puts "ERROR [#{e[:file]}]: #{e[:message]}" }
      warnings.first(50).each { |w| puts "WARN  [#{w[:file]}]: #{w[:message]}" }
      puts "(... #{errors.size - 50} more errors)" if errors.size > 50
      puts "(... #{warnings.size - 50} more warnings)" if warnings.size > 50
    end

    errors.empty? && (!strict || warnings.empty?)
  end

  def validate_root_files(errors, warnings)
    if File.exist?(ROOT_INDEX)
      data, _fm_str, _body, err = parse_frontmatter(ROOT_INDEX)
      if err
        errors << { file: "index.md", message: err }
      elsif data["okf_version"].to_s.empty?
        errors << { file: "index.md", message: "Root index.md must declare okf_version (e.g. \"0.2\")" }
      end
    else
      errors << { file: "index.md", message: "Missing root index.md" }
    end

    if File.exist?(ROOT_LOG)
      log_txt = File.read(ROOT_LOG, encoding: "UTF-8")
      unless log_txt.match?(/^## \d{4}-\d{2}-\d{2}\b/)
        warnings << { file: "log.md", message: "log.md has no ## YYYY-MM-DD entries yet" }
      end
    else
      errors << { file: "log.md", message: "Missing root log.md" }
    end
  end

  def validate_directories(errors, _warnings)
    post_directories.each do |dir|
      index_path = File.join(dir, "index.md")
      rel_index = index_path.sub("#{ROOT}/", "")
      unless File.exist?(index_path)
        errors << { file: rel_index, message: "Missing directory index.md" }
        next
      end

      content = File.read(index_path, encoding: "UTF-8")
      # Verify every direct child post and subdirectory index is referenced.
      Dir.children(dir).sort.each do |entry|
        full = File.join(dir, entry)
        if File.directory?(full)
          next unless post_directories.include?(full)
          unless content.include?("./#{entry}/index.md")
            errors << { file: rel_index, message: "Missing subdirectory link ./#{entry}/index.md" }
          end
        elsif entry.end_with?(".md") && !%w[index.md log.md].include?(entry)
          unless content.include?("./#{entry}")
            errors << { file: rel_index, message: "Post ./#{entry} is missing from index.md" }
          end
        end
      end

      # Check for broken relative links inside index.md.
      content.scan(/\]\((\.[^)]+)\)/).flatten.each do |target|
        target_path = File.expand_path(target, dir)
        unless File.exist?(target_path)
          errors << { file: rel_index, message: "Broken relative link #{target}" }
        end
      end
    end
  end

  def validate_post_frontmatter(rel_path, data, fm_str, strict, errors, warnings)
    type_val = data["type"]
    if !type_val.is_a?(String) || type_val.strip.empty?
      errors << { file: rel_path, message: "Missing required OKF field: type" }
    elsif !ALLOWED_TYPES.include?(type_val)
      msg = "Unregistered OKF type '#{type_val}' (expected one of: #{ALLOWED_TYPES.join(', ')})"
      strict ? errors << { file: rel_path, message: msg } : warnings << { file: rel_path, message: msg }
    end

    if data["title"].to_s.strip.empty?
      errors << { file: rel_path, message: "Missing title" }
    end

    desc = data["description"]
    if !desc.is_a?(String) || desc.strip.empty?
      errors << { file: rel_path, message: "Missing description" }
    elsif desc.match?(/["<>]|{{|{%|\n/)
      errors << { file: rel_path, message: "description contains unsafe HTML/Liquid characters or newline" }
    end

    tags = data["tags"]
    if !tags.is_a?(Array) || tags.empty? || tags.any? { |t| !t.is_a?(String) || t.strip.empty? }
      errors << { file: rel_path, message: "tags must be a non-empty YAML list of strings" }
    end

    status = data["status"]
    if !status.is_a?(String) || !ALLOWED_STATUSES.include?(status)
      errors << { file: rel_path, message: "status must be one of #{ALLOWED_STATUSES.join(', ')}" }
    else
      is_jekyll_draft = (data["draft"] == true) || (data["published"] == false)
      if is_jekyll_draft && status == "stable"
        warnings << { file: rel_path, message: "Jekyll draft/unpublished post has status: stable" }
      end
    end

    if data.key?("stale_after") && !data["stale_after"].nil?
      unless valid_iso_offset_timestamp?(data["stale_after"], fm_str, "stale_after")
        errors << { file: rel_path, message: "stale_after must be ISO 8601 datetime with explicit UTC offset (e.g. 2027-01-01T00:00:00Z)" }
      end
    end

    validate_actor_event(rel_path, "generated", data["generated"], fm_str, errors) if data.key?("generated")

    if data.key?("verified") && !data["verified"].nil?
      if data["verified"].is_a?(Array)
        data["verified"].each_with_index do |ev, idx|
          validate_actor_event(rel_path, "verified[#{idx}]", ev, fm_str, errors, key_hint: "at")
        end
      else
        errors << { file: rel_path, message: "verified must be a list of {by, at} entries" }
      end
    end

    if data.key?("sources") && !data["sources"].nil?
      if data["sources"].is_a?(Array)
        data["sources"].each_with_index do |src, idx|
          unless src.is_a?(Hash) && !src["id"].to_s.empty? && (!src["resource"].to_s.empty? || !src["title"].to_s.empty?)
            errors << { file: rel_path, message: "sources[#{idx}] must include id and resource/title" }
          end
          if src.is_a?(Hash) && src.key?("last_modified") && !src["last_modified"].nil?
            unless valid_iso_offset_timestamp?(src["last_modified"], fm_str, "last_modified")
              errors << { file: rel_path, message: "sources[#{idx}].last_modified must be ISO 8601 with UTC offset" }
            end
          end
        end
      else
        errors << { file: rel_path, message: "sources must be a list" }
      end
    end
  end

  def validate_actor_event(rel_path, label, obj, fm_str, errors, key_hint: "at")
    unless obj.is_a?(Hash) && obj["by"].is_a?(String) && obj["by"].match?(ACTOR_RE)
      errors << { file: rel_path, message: "#{label}.by must match human:<id>, process:<id>, or <agent>/<model>" }
    end
    unless obj.is_a?(Hash) && valid_iso_offset_timestamp?(obj["at"], fm_str, key_hint)
      errors << { file: rel_path, message: "#{label}.at must be ISO 8601 datetime with explicit UTC offset" }
    end
  end

  def stale_report(as_of: Time.now.utc, limit: nil, category: nil, include_upcoming_days: 30, json_out: false)
    expired = []
    upcoming = []
    total_tracked = 0

    post_files.each do |abs_path|
      rel_path = abs_path.sub("#{ROOT}/", "")
      data, _fm, _body, err = parse_frontmatter(abs_path)
      next if err
      next if %w[draft deprecated].include?(data["status"])
      next if category && !data["category"].to_s.casecmp?(category)

      stale_val = data["stale_after"]
      next unless stale_val

      stale_time = to_utc_time(stale_val)
      next unless stale_time

      total_tracked += 1
      days_diff = ((as_of - stale_time) / 86_400.0).floor
      entry = {
        path: rel_path,
        title: data["title"].to_s,
        category: data["category"].to_s,
        type: data["type"].to_s,
        stale_after: stale_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        days_overdue: days_diff,
        verified_count: data["verified"].is_a?(Array) ? data["verified"].size : 0,
        sources_count: data["sources"].is_a?(Array) ? data["sources"].size : 0
      }

      if as_of >= stale_time
        expired << entry
      elsif (stale_time - as_of) <= include_upcoming_days * 86_400
        upcoming << entry
      end
    end

    # Prioritize newer articles that recently expired or have fewer verifications, then oldest overdue.
    expired.sort_by! { |e| [e[:verified_count], -e[:days_overdue], e[:path]] }
    upcoming.sort_by! { |e| [-e[:days_overdue], e[:path]] }

    display_expired = limit ? expired.first(limit) : expired

    if json_out
      puts JSON.pretty_generate(
        as_of: as_of.strftime("%Y-%m-%dT%H:%M:%SZ"),
        total_with_stale_after: total_tracked,
        expired_count: expired.size,
        upcoming_count: upcoming.size,
        expired: display_expired,
        upcoming: upcoming
      )
    else
      puts "# OKF Freshness Report (#{as_of.strftime('%Y-%m-%d %H:%M:%S UTC')})"
      puts ""
      puts "- Tracked posts (`stale_after` set, active): #{total_tracked}"
      puts "- Expired (`now >= stale_after`): #{expired.size}"
      puts "- Expiring within #{include_upcoming_days} days: #{upcoming.size}"
      puts ""
      if display_expired.empty?
        puts "No expired articles found."
      else
        puts "## Expired Articles (Showing #{display_expired.size} of #{expired.size})"
        puts ""
        puts "| Category | Type | Stale After | Overdue (days) | Path | Title |"
        puts "|---|---|---|---:|---|---|"
        display_expired.each do |e|
          puts "| #{e[:category]} | #{e[:type]} | #{e[:stale_after][0, 10]} | #{e[:days_overdue]} | `#{e[:path]}` | #{e[:title].gsub('|', '\\|')} |"
        end
      end
      unless upcoming.empty?
        puts ""
        puts "## Expiring Within #{include_upcoming_days} Days"
        puts ""
        upcoming.each do |u|
          puts "- `#{u[:path]}` (#{u[:stale_after][0, 10]}) — #{u[:title]}"
        end
      end
    end
  end

  def sync_index
    dirs = post_directories
    dir_stats = {}

    # Compute stats per directory bottom-up.
    dirs.reverse_each do |dir|
      children_dirs = Dir.children(dir)
                         .map { |e| File.join(dir, e) }
                         .select { |p| File.directory?(p) && dirs.include?(p) }
                         .sort
      direct_posts = Dir.children(dir)
                        .select { |e| e.end_with?(".md") && !%w[index.md log.md].include?(e) }
                        .map { |e| File.join(dir, e) }
                        .sort
                        .reverse

      parsed_posts = direct_posts.map do |p|
        data, _fm, _body, err = parse_frontmatter(p)
        { path: p, name: File.basename(p), data: data || {}, err: err }
      end

      total_posts = parsed_posts.size + children_dirs.sum { |cd| dir_stats[cd][:total_posts] }
      dir_stats[dir] = { total_posts: total_posts, direct_posts: parsed_posts.size }

      next if dir == POSTS_DIR

      rel_dir = dir.sub("#{POSTS_DIR}/", "")
      lines = [
        "# #{rel_dir}",
        "",
        "Parent: [All Categories](#{'../' * rel_dir.count('/')}../index.md)",
        ""
      ]

      unless children_dirs.empty?
        lines << "## Subcategories"
        lines << ""
        children_dirs.each do |cd|
          sub_name = File.basename(cd)
          lines << "- [#{sub_name}/](./#{sub_name}/index.md) (#{dir_stats[cd][:total_posts]} posts)"
        end
        lines << ""
      end

      unless parsed_posts.empty?
        lines << "## Articles (#{parsed_posts.size})"
        lines << ""
        parsed_posts.each do |post|
          d = post[:data]
          title = d["title"].to_s.empty? ? post[:name] : d["title"].to_s
          desc = d["description"].to_s
          meta = [d["type"] || "Unknown", d["status"] || "stable"]
          if d["stale_after"] && (t = to_utc_time(d["stale_after"]))
            meta << "stale_after: #{t.strftime('%Y-%m-%d')}"
          end
          line = "- [#{title}](./#{post[:name]}) (`#{meta.join(' | ')}`)"
          line += " — #{desc}" unless desc.empty?
          lines << line
        end
        lines << ""
      end

      File.write(File.join(dir, "index.md"), lines.join("\n"), encoding: "UTF-8")
    end

    write_posts_root_index(dirs, dir_stats)
    update_repo_root_index(dirs, dir_stats)
    puts "Synchronized #{dirs.size} index.md files under _posts/ and root index.md"
  end

  def write_posts_root_index(dirs, dir_stats)
    top_dirs = dirs.select { |d| File.dirname(d) == POSTS_DIR }.sort
    total = dir_stats[POSTS_DIR][:total_posts]
    lines = [
      "# Blog Posts Index",
      "",
      "Root: [Bundle Index](../index.md) | Changelog: [log.md](../log.md)",
      "",
      "Total posts: **#{total}** across **#{dirs.size - 1}** directories.",
      "",
      "## Categories",
      "",
      "| Category | Posts | Index |",
      "|---|---:|---|"
    ]
    top_dirs.each do |td|
      name = File.basename(td)
      lines << "| #{name} | #{dir_stats[td][:total_posts]} | [./#{name}/index.md](./#{name}/index.md) |"
    end
    lines << ""
    File.write(File.join(POSTS_DIR, "index.md"), lines.join("\n"), encoding: "UTF-8")
  end

  def update_repo_root_index(dirs, dir_stats)
    return unless File.exist?(ROOT_INDEX)

    content = File.read(ROOT_INDEX, encoding: "UTF-8")
    return unless content.include?(INDEX_START_MARKER) && content.include?(INDEX_END_MARKER)

    top_dirs = dirs.select { |d| File.dirname(d) == POSTS_DIR }.sort
    total = dir_stats[POSTS_DIR][:total_posts]
    block = [
      INDEX_START_MARKER,
      "Total articles: **#{total}** across **#{top_dirs.size}** top-level categories ([full category map](./_posts/index.md)).",
      "",
      "| Category | Articles | Index |",
      "|---|---:|---|"
    ]
    top_dirs.each do |td|
      name = File.basename(td)
      block << "| #{name} | #{dir_stats[td][:total_posts]} | [_posts/#{name}/index.md](./_posts/#{name}/index.md) |"
    end
    block << INDEX_END_MARKER

    updated = content.sub(/#{Regexp.escape(INDEX_START_MARKER)}.*?#{Regexp.escape(INDEX_END_MARKER)}/m, block.join("\n"))
    File.write(ROOT_INDEX, updated, encoding: "UTF-8")
  end

  def append_log(action:, path:, summary:, actor: nil, date_str: Time.now.getlocal("+09:00").strftime("%Y-%m-%d"))
    raise ArgumentError, "log.md does not exist at #{ROOT_LOG}" unless File.exist?(ROOT_LOG)

    content = File.read(ROOT_LOG, encoding: "UTF-8")
    entry_link = path.start_with?("./") ? path : "./#{path}"
    actor_note = actor && !actor.empty? ? " (`#{actor}`)" : ""
    entry_line = "- **#{action}**: [#{path}](#{entry_link}) — #{summary}#{actor_note}"
    heading = "## #{date_str}"

    if content.include?(heading)
      updated = content.sub(/^(#{Regexp.escape(heading)}\n)/, "\\1#{entry_line}\n")
    elsif content =~ /^## \d{4}-\d{2}-\d{2}/
      updated = content.sub(/^(## \d{4}-\d{2}-\d{2})/, "#{heading}\n#{entry_line}\n\n\\1")
    else
      updated = "#{content.rstrip}\n\n#{heading}\n#{entry_line}\n"
    end

    File.write(ROOT_LOG, updated, encoding: "UTF-8")
    puts "Logged to log.md under #{heading}: #{entry_line}"
  end
end

if __FILE__ == $PROGRAM_NAME
  cmd = ARGV.shift
  case cmd
  when "validate"
    opts = { strict: false, json: false }
    OptionParser.new do |o|
      o.on("--strict") { opts[:strict] = true }
      o.on("--json") { opts[:json] = true }
    end.parse!(ARGV)
    ok = OKF.validate(strict: opts[:strict], json_out: opts[:json])
    exit(ok ? 0 : 1)
  when "stale"
    opts = { as_of: Time.now.utc, limit: nil, category: nil, days: 30, json: false }
    OptionParser.new do |o|
      o.on("--as-of TIME") { |v| opts[:as_of] = Time.parse(v).utc }
      o.on("--limit N", Integer) { |v| opts[:limit] = v }
      o.on("--category CAT") { |v| opts[:category] = v }
      o.on("--upcoming-days N", Integer) { |v| opts[:days] = v }
      o.on("--json") { opts[:json] = true }
    end.parse!(ARGV)
    OKF.stale_report(
      as_of: opts[:as_of],
      limit: opts[:limit],
      category: opts[:category],
      include_upcoming_days: opts[:days],
      json_out: opts[:json]
    )
  when "sync-index"
    OKF.sync_index
  when "log"
    opts = { action: "Update", path: nil, summary: nil, actor: nil, date: Time.now.getlocal("+09:00").strftime("%Y-%m-%d") }
    OptionParser.new do |o|
      o.on("--action ACTION") { |v| opts[:action] = v }
      o.on("--path PATH") { |v| opts[:path] = v }
      o.on("--summary TEXT") { |v| opts[:summary] = v }
      o.on("--actor ACTOR") { |v| opts[:actor] = v }
      o.on("--date YYYY-MM-DD") { |v| opts[:date] = v }
    end.parse!(ARGV)
    abort("--path and --summary are required") if opts[:path].to_s.empty? || opts[:summary].to_s.empty?
    OKF.append_log(
      action: opts[:action],
      path: opts[:path],
      summary: opts[:summary],
      actor: opts[:actor],
      date_str: opts[:date]
    )
  else
    warn "Usage: ruby scripts/okf.rb <validate|stale|sync-index|log> [options]"
    exit 1
  end
end
