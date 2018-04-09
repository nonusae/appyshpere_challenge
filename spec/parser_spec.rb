require 'spec_helper'
require_relative '../bin/parser'

RSpec.describe 'parser script file' do

  describe '#data_from_keyword' do
    let(:line) { '2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.106" home_id=web.8 connect=9ms service=9ms status=304 bytes=0'}
    let(:keyword) { 'path' }

    it { expect(data_from_keyword(line,keyword)).to eq('/api/users/100002266342173/get_all_cameras')}
  end
  describe '#mean' do
    context "normal input array" do
      let(:input_array) { [2,3,4,5] }

      it { expect(mean(input_array)).to eq 3.5 }
    end

    context 'empty array' do
      let(:input_array) { [] }
      it { expect(mean(input_array)).to eq 'N/A' }
    end
  end

  describe '#median' do
    context "normal input array" do
      let(:input_array) { [3, 13, 7, 5, 21, 23, 39, 23, 40, 23, 14, 12, 56, 23, 29] }

      it { expect(median(input_array)).to eq 23 }
    end

    context 'empty array' do
      let(:input_array) { [] }
      it { expect(median(input_array)).to eq 'N/A' }
    end
  end

  describe '#mode' do
    context "normal input array" do
      let(:input_array) { [6, 3, 9, 6, 6, 5, 9, 3] }

      it { expect(mode(input_array)).to eq 6 }
    end

    context 'empty array' do
      let(:input_array) { [] }
      it { expect(mode(input_array)).to eq 'N/A' }
    end
  end

  describe '#total_camera_call_by_home' do
    let(:lines) { ['2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.106" home_id=web.8 connect=9ms service=9ms status=304 bytes=0',
                   '2014-01-09T06:16:53.742562+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342180/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.206" home_id=web.8 connect=9ms service=9ms status=304 bytes=0',
                   '2014-01-09T06:20:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266350173/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.220" home_id=web.7 connect=9ms service=9ms status=304 bytes=0']}

    it { expect(total_camera_call_by_home(lines)).to eq({"web.8"=>2, "web.7"=>1}) }
  end

  describe '#total_response_time_by_url' do
    let(:lines) { ['2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.106" home_id=web.8 connect=9ms service=9ms status=304 bytes=0',
                   '2014-01-09T06:16:53.742562+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342180/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.206" home_id=web.8 connect=9ms service=23ms status=304 bytes=0',
                   '2014-01-09T06:20:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266350173/get_all_cameras host=services.appysphere.com ip_camera="94.66.255.220" home_id=web.7 connect=9ms service=44ms status=304 bytes=0']}

    it { expect(total_response_time_by_url(lines)).to eq [18, 32, 53] }
  end

  describe '#device_ranking_by_service_time' do
    let(:lines) { ['2014-01-09T06:16:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342173/get_camera host=services.appysphere.com ip_camera="A" home_id=web.5 connect=9ms service=9ms status=304 bytes=0',
                   '2014-01-09T06:16:53.742562+00:00 heroku[router]: at=info method=GET path=/api/users/100002266342180/get_camera host=services.appysphere.com ip_camera="B" home_id=web.8 connect=9ms service=44ms status=304 bytes=0',
                   '2014-01-09T06:20:53.742892+00:00 heroku[router]: at=info method=GET path=/api/users/100002266350173/get_camera host=services.appysphere.com ip_camera="C" home_id=web.7 connect=9ms service=23ms status=304 bytes=0']}

    it { expect(device_ranking_by_service_time(lines,3)).to eq [{:device=>"A", :service_time=>9},
                                                               {:device=>"C", :service_time=>23},
                                                               {:device=>"B", :service_time=>44} ] }
  end

end


