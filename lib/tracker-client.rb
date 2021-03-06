# encoding: utf-8
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'pry'

class TrackerClient
  def initialize(key, project, requester_id)
    @api_key = key
    @project_id = project
    @requester_id = requester_id
    raise 'invalid api key for tracker' unless validate_string @api_key
    raise 'invalid project id for tracker' unless validate_string @project_id
    raise 'invalid requester id for tracker' unless validate_number @requester_id
  end

  def search_by_name(name:)
    search_with_filters(name: name)
  end

  def search_by_label(label:)
    search_with_filters(label: label)
  end

  def search_with_filters(filters)
    response = http_request do |uri|
      uri.query = "filter=#{filters.map { |k,v| v.is_a?(Array) ? v.map { |vv| "#{k}:#{vv}" } : "#{k}:#{v}" }.flatten.join(" AND ")}"
      Net::HTTP::Get.new(uri)
    end
    JSON.parse(response.body)
  end

  def post_to_tracker(name:, description:, tasks: [], point_value: nil, labels: [])
    name = name.to_s
    raise 'requested tracker story has no name' unless validate_string name
    raise 'requested tracker story has no description' unless validate_string description

    task_api_objs = tasks.map { |task| { description: task } }
    label_api_objs = labels.map { |label| { name: label } }

    payload = {
      name: name,
      description: description,
      requested_by_id: @requester_id,
      tasks: task_api_objs,
      labels: label_api_objs
    }

    payload[:estimate] = point_value if point_value

    response = http_request do |uri|
      request = Net::HTTP::Post.new(uri)
      request.body = payload.to_json
      request
    end
    response
  end

  def add_blocker_to_story(story_id:, blocker:)
    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story_id}/blockers")
      request = Net::HTTP::Post.new(uri)
      request.body = {
        description: "##{blocker.id} - #{blocker.name}",
        person_id: @requester_id,
        resolved: (blocker.current_state == 'accepted')
      }.to_json
      request
    end
  end

  def overwrite_label_on_story(story:, existing_label_regex:, new_label:)
    existing_labels_with_ids = story["labels"].map { |l| l.select { |key| ["name", "id", "project_id"].include?(key) } }
    existing_labels_with_ids.select! { |l| !l['name'].match(existing_label_regex) }
    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story["id"]}")
      request = Net::HTTP::Put.new(uri)
      request.body = {
        labels: [ { name: new_label } ] + existing_labels_with_ids
      }.to_json
      request
    end
  end

  def add_label_to_story(story:, label:)
    existing_labels_with_ids = story["labels"].map { |l| l.select { |key| ["name", "id", "project_id"].include?(key) } }

    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story["id"]}")
      request = Net::HTTP::Put.new(uri)
      request.body = {
        labels: [ { name: label } ] + existing_labels_with_ids
      }.to_json
      request
    end
  end

  def add_comment_to_story(story_id:, comment:)
    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story_id}/comments")
      request = Net::HTTP::Post.new(uri)
      request.body = {
        text: comment
      }.to_json
      request
    end
  end

  def change_story_state(story_id:, current_state:)
    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story_id}")
      request = Net::HTTP::Put.new(uri)
      request.body = {
        current_state: current_state
      }.to_json
      request
    end
  end

  def point_story(story_id:, estimate:)
    http_request do |uri|
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{story_id}")
      request = Net::HTTP::Put.new(uri)
      request.body = {
        estimate: estimate
      }.to_json
      request
    end
  end

  def find_unaccepted_story_ids(text_to_search_for)
    search_by_name(name: text_to_search_for).select do |story|
      story['current_state'] != 'accepted'
    end.map do |story|
      story['id']
    end
  end

  private

  def validate_string(cred)
    !(cred.nil? || !cred.is_a?(String) || cred.empty?)
  end

  def validate_number(cred)
    !(cred.nil? || !cred.is_a?(Numeric))
  end

  def http_request(&block)
    uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories")
    request = block.call(uri)
    request['Content-Type'] = 'application/json'
    request['X-TrackerToken'] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise response.message if response.code != '200'

    response
  end
end
