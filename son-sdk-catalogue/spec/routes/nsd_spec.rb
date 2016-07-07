##
## Copyright (c) 2015 SONATA-NFV, i2CAT Foundation
## ALL RIGHTS RESERVED.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).

require_relative '../spec_helper'
require 'webmock/rspec'
require 'json'
require 'securerandom'
require 'pp'
require 'rspec/its'

RSpec.describe SonataCatalogue do
  def app
    @app ||= SonataCatalogue
  end

  describe 'GET \'/\'' do
    before do
      stub_request(:get, 'localhost:4011').to_return(status: 200)
      get '/'
    end
    subject { last_response }
    its(:status) { is_expected.to eq 200 }
  end

  let(:ns_descriptor) {Rack::Test::UploadedFile.new('./spec/fixtures/nsd-example.json','application/json', true)}
  describe 'POST \'/network-services\'' do
    context 'with correct parameters' do
      it 'Submit an nsd' do
        headers = { 'CONTENT_TYPE' => 'application/json' }
        post '/network-services', ns_descriptor, headers
        expect(last_response.status).to eq(200)
        nsd_body = JSON.parse(last_response.body)
        $nsd_id = (nsd_body['_id'])
      end
    end
  end

  let(:ns_descriptor) {Rack::Test::UploadedFile.new('./spec/fixtures/nsd-example.json','application/json', true)}
  describe 'POST \'/network-services\'' do
    context 'Duplicated nsd' do
      it 'Submit a duplicated nsd' do
        headers = { 'CONTENT_TYPE' => 'application/json' }
        post '/network-services', ns_descriptor, headers
        expect(last_response.status).to eq(200)
      end
    end
  end

  let(:ns_bad_descriptor) {Rack::Test::UploadedFile.new('./spec/fixtures/nsd-example-with-errors.json','application/json', true)}
  describe 'POST \'/network-services-bad\'' do
    context 'with incorrect parameters' do
      it 'Submit an invalid nsd' do
        headers = { 'CONTENT_TYPE' => 'application/json' }
        post '/network-services', ns_bad_descriptor, headers
        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'GET /network-services' do
    context 'without ID given' do
      before do
        headers = { 'CONTENT_TYPE' => 'application/json' }
        get '/network-services', nil, headers
      end
      subject { last_response }
      its(:status) { is_expected.to eq 200 }
    end
  end

  describe 'GET /network-services/id/:id' do
    context 'with ID given' do
      before do
        headers = { 'CONTENT_TYPE' => 'application/json' }
        $nsd_id = 'u1XvQWLbFaQQn.X8rBMr9pRwJSAZy5WhBFy8_OUt9-SzGOAR.490Oc4Ns.XtUN_8QhIJ6VXKbXza.TdAy08kC4.X8rBMr9pRwJSAZy5WhBFy8_OUt9-SzGOAR.490Oc4Ns.XtUN_8QhIJ6VXKbXza.TdAy08kC4.u1XvQWLbFaQQn.582508180021607734924847085465088203416134071781801715084959918018529773253144941917518789'
        get '/network-services/id/' + $nsd_id.to_s, nil, headers
      end
      subject { last_response }
      its(:status) { is_expected.to eq 200 }
    end
  end

  describe 'DELETE /network-services/id/:id' do
    context 'with (UU)ID given' do
      before do
        delete '/network-services/id/' + $nsd_id.to_s
      end
      subject { last_response }
      its(:status) { is_expected.to eq 200 }
    end
  end
end