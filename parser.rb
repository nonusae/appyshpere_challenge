
file='sample_appysphere.log'


GET_CAMERA_ENDPOINT = /(GET:\/api\/users\/)(\d+.)(\/get_camera)/
GET_ALL_CAMERA_ENDPOINT = /(GET:\/api\/users\/)(\d+.)(\/get_all_cameras)/
GET_HOME_ENDPOINT = /(GET:\/api\/users\/)(\d+.)(\/get_home)/
POST_USERS_ENDPOINT = /^(POST:\/api\/users\/)(\d+.)$/
GET_USERS_ENDPOINT = /^(GET:\/api\/users\/)(\d+.)$/

ALLOW_ENDPOINT = Regexp.union(GET_CAMERA_ENDPOINT,
                              GET_ALL_CAMERA_ENDPOINT,
                              GET_HOME_ENDPOINT,
                              POST_USERS_ENDPOINT,
                              GET_USERS_ENDPOINT
                              )

get_camera_lines = []
get_all_camera_lines = []
get_home_lines = []
get_users_lines = []
post_users_lines = []

def data_from_keyword(line,keyword)
  matching = line.match(/(?<=#{keyword}=)(.([^\s]+))/)
  if matching
    return matching[0]
  end
end

def median(arr)
  return "N/A" if arr.empty?
  sorted = arr.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

def mean(arr)
  return "N/A" if arr.empty?
  (arr.sum / arr.count).round(2)
end

def mode(arr)
  return "N/A" if arr.empty?

  frequency = arr.each_with_object(Hash.new(0)) { |v, h| h[v] += 1 }
  arr.max_by { |v| frequency[v] }
end


File.readlines(file).each do |line|
  path = data_from_keyword(line,'path')
  method = data_from_keyword(line,'method')
  path_method =  method+':'+path

  if path_method =~  ALLOW_ENDPOINT
    if path_method =~ GET_CAMERA_ENDPOINT
      get_camera_lines << line
    elsif path_method =~ GET_ALL_CAMERA_ENDPOINT
      get_all_camera_lines << line
    elsif path_method =~ GET_HOME_ENDPOINT
      get_home_lines << line
    elsif path_method =~ GET_USERS_ENDPOINT
      get_users_lines << line
    elsif path_method =~ POST_USERS_ENDPOINT
      post_users_lines << line
    end
  end
end

## Get Total every camera call sort by home
def total_camera_call_by_home(lines)
  answer = {}
  mapped_array = lines.map { |line| { home_id: data_from_keyword(line,'home_id') } }
  group_by_home = mapped_array.group_by { |hash| hash[:home_id] }
  group_by_home.each { |k,v| answer[k] = v.count}

  return answer
end


def total_response_time_by_url(lines)
  response_time_array = lines.map do |line|
    connect_time = data_from_keyword(line,'connect').gsub('ms','').to_i
    service_time = data_from_keyword(line,'service').gsub('ms','').to_i
    response_time = connect_time + service_time
  end

  return response_time_array
end

def device_ranking_by_service_time(lines,number_of_rank)
  mapped_array = lines.map do |line|
    service_time = data_from_keyword(line,'service').gsub('ms','').to_i
    device =  data_from_keyword(line,'ip_camera')
    { device: device.gsub('"',"") , service_time: service_time }
  end

  mapped_array.sort_by { |hash| hash[:service_time]}[0..number_of_rank-1]
end



## Logger

get_camera_total_camera_hit = total_camera_call_by_home(get_camera_lines)
get_all_camera_total_camera_hit = total_camera_call_by_home(get_all_camera_lines)
get_home_total_camera_hit = total_camera_call_by_home(get_home_lines)
get_users_total_camera_hit = total_camera_call_by_home(get_users_lines)
post_users_total_camera_hit = total_camera_call_by_home(post_users_lines)


puts "##### This is some simeple analysis of our home camera api ####"
puts "1.The number of times every camera was called segmented per home"
puts "\nFor GET /api/users/{user_id}/get_camera"
get_camera_total_camera_hit.each do  |home,total_camera_hit|
  puts "Home '#{home}' camera hit #{total_camera_hit} times"
end

puts "\nFor GET /api/users/{user_id}/get_home"
get_home_total_camera_hit.each do  |home,total_camera_hit|
  puts "Home '#{home}' camera hit #{total_camera_hit} times"
end

puts "\nFor GET /api/users/{user_id}/get_all_cameras"
get_all_camera_total_camera_hit.each do  |home,total_camera_hit|
  puts "Home '#{home}' camera hit #{total_camera_hit} times"
end

puts "\nFor POST /api/users/{user_id}"
post_users_total_camera_hit.each do  |home,total_camera_hit|
  puts "Home '#{home}' camera hit #{total_camera_hit} times"
end

puts "\nFor GET /api/users/{user_id}"
get_users_total_camera_hit.each do  |home,total_camera_hit|
  puts "Home '#{home}' camera hit #{total_camera_hit} times"
end


puts "\n\n2.The mean (average), median and mode of the response time (connect time + service time) for each URL's"
puts "\nFor GET /api/users/{user_id}/get_camera"
puts "Mean is #{mean(total_response_time_by_url(get_camera_lines))} ms"
puts "Median is #{median(total_response_time_by_url(get_camera_lines))} ms"
puts "Mode is #{mode(total_response_time_by_url(get_camera_lines))} ms"

puts "\nFor GET /api/users/{user_id}/get_home"
puts "Mean is #{mean(total_response_time_by_url(get_home_lines))} ms"
puts "Median is #{median(total_response_time_by_url(get_home_lines))} ms"
puts "Mode is #{mode(total_response_time_by_url(get_home_lines))} ms"

puts "\nFor GET /api/users/{user_id}/get_all_cameras"
puts "Mean is #{mean(total_response_time_by_url(get_all_camera_lines))} ms"
puts "Median is #{median(total_response_time_by_url(get_all_camera_lines))} ms"
puts "Mode is #{mode(total_response_time_by_url(get_all_camera_lines))} ms"

puts "\nFor POST /api/users/{user_id}"
puts "Mean is #{mean(total_response_time_by_url(post_users_lines))} ms"
puts "Median is #{median(total_response_time_by_url(post_users_lines))} ms"
puts "Mode is #{mode(total_response_time_by_url(post_users_lines))} ms"

puts "\nFor GET /api/users/{user_id}"
puts "Mean is #{mean(total_response_time_by_url(get_users_lines))} ms"
puts "Median is #{median(total_response_time_by_url(get_users_lines))} ms"
puts "Mode is #{mode(total_response_time_by_url(get_users_lines))} ms"


ranked_devices = device_ranking_by_service_time(get_camera_lines,10)
puts "\n\n3.Ranking of the devices (get camera) (per service time)"
puts "Top ten devices sort by service time"
ranked_devices.each_with_index do |data,i|
  puts "Rank #{i+1}: Device ip '#{data[:device]}', service time #{data[:service_time]}"
end