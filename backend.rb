require 'sinatra'
require 'sinatra/reloader'
require 'json'

set :port, 8089
#set :environment, :development
set :environment, :production
set :server, 'webrick'


class DryCode
	def convert_json
		new_hash = {}
		@string = ''
		@mm = ''
		@ss = ''

		file = './public/results.json'
		json_file = File.read(file)

		converted_file = JSON.parse(json_file)

		converted_file.each do |item|
			item["result"].each do |result_item|
				if result_item[0] == "rag_status"
					@rag_status = result_item[1]
				end
				if result_item[0] == "url"
					@url = result_item[1]
				end
				if result_item[0] == "priority"
					@priority = result_item[1]
				end
			end
			captalised_profile = item["wp_title"]
			new_hash[captalised_profile] = {}
			new_hash[captalised_profile]['rag_status'] = @rag_status
			new_hash[captalised_profile]['url'] = @url
			new_hash[captalised_profile]['priority'] = @priority.to_i
		end

		new_hash = new_hash.sort_by { |k, v| v['priority'] }
		#new_hash = Hash[new_hash.sort]

		puts '#######################'
		puts new_hash
		puts '#######################'
		new_hash
	end

	def get_width (root)
		number_of_rows = 0
		width_value = 0

		if root == root.round
			number_of_rows = root
			width_value = 100.to_f/number_of_rows
		else
			number_of_rows = root + 1
			width_value = 100.to_f/root.to_i
		end

		@width_value = width_value.to_s
	end

	def get_height (root)
		number_of_rows = 0
		height_value = 0

		if root == root.round
			number_of_rows = root
			height_value = 100.to_f/number_of_rows
		else
			number_of_rows = root + 1
			height_value = 100.to_f/number_of_rows.round
		end

		@height_value = height_value.to_s
	end
end

class_obj = DryCode.new

get '/dashboard' do
	new_hash = class_obj.convert_json

	item_count = 0
	new_hash.each do |item|
		item_count = item_count + 1
	end

	root = Math.sqrt(item_count)

	width_value = class_obj.get_width(root)
	height_value = class_obj.get_height(root)

	@width_value = width_value
	@height_value = height_value
	@new_hash = new_hash
	erb :dashboard_view
end

get '/edit' do
	erb :edit_view
end


post '/update_json' do
	wp_title = params["wp_title"]
	this_week = params["this_week"]
	next_week = params["next_week"]
	rag_status = params["rag_status"]
	rag_justification = params["rag_justification"]
	risks = params["risks"]

	file = './public/results.json'
	json_file = File.read(file)
	file_trim = json_file.tr("]", "")

	new_hash = {}

	new_json = ',{"wp_title":"' + wp_title + '","result":{"this_week":"' + this_week + '","next_week":"' + next_week + '","rag_status":"' + rag_status + '","rag_justification":"' + rag_justification + '","risks":"' + risks + '"}}'

	new_file = file_trim + new_json + ']'

	File.write(file, new_file)

	new_hash = class_obj.convert_json

	item_count = 0
	new_hash.each do |item|
		item_count = item_count + 1
	end

	root = Math.sqrt(item_count)

	width_value = class_obj.get_width(root)
	height_value = class_obj.get_height(root)

	@width_value = width_value
	@height_value = height_value
	@new_hash = new_hash

	erb :dashboard_view
end
