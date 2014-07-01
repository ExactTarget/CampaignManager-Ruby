=begin
Copyright (c) 2013 ExactTarget, Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 

following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 

following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 

following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 

products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 

INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 

DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 

SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 

SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 

WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 

USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

class Main < Sinatra::Base
	
	## GET Login Endpoint configured so that the ClientID/Client Secret will be loaded from the config.yaml 
	get '/login' do		
		if !session.has_key?(:authstub) || session[:authstub].nil? then
			session[:authstub] = ET_Client.new
		end
		redirect '/'
	end	
	
	## POST Login Endpoint configured so that the JWT will be used to provide context for the application
	post '/login' do		
		if !session.has_key?(:authstub) || session[:authstub].nil? then
			session[:authstub] = ET_Client.new(false, false, request.POST)
			p 'session created'
		end
		redirect '/'
	end	
	
	get '/logout' do
		session[:authstub] = nil
	end	
	
	## 1. Display Create Campaign Form with Left Nav
	get '/' do		
		# Retrieve the campaigns for the left nav
		camp = ET_Campaign.new
		camp.authStub = session[:authstub]		
		campResponse = camp.get
		@camps = campResponse.results['items']
		
		# Define Colors for the Form's Drop Down
		@colors = [	'D1EE68','CFBA31','23B049','E25822','F0A94E','EDEE68','E02516','F59682']
		
		haml :'pages/home'
	end
	
	## 2. Handle Form Post from Create Campaign Page and Redirect to Details page
	post '/campaign' do						
		postParams = request.POST				
		newCampaign = ET_Campaign.new
		newCampaign.authStub = session[:authstub]
		# Pass through the post parameters exactly as they were passed from the form
		newCampaign.props = params
		postResponse = newCampaign.post
		p postResponse
		
		if postResponse.status then 
			newID = postResponse.results['id']
			redirect "/campaign/#{newID}"
		end 
	end

	## 3. Display page with Campaign Details
	get '/campaign/:id' do
		# Retrieve the campaigns for the left nav
		camp = ET_Campaign.new
		camp.authStub = session[:authstub]		
		campResponse = camp.get
		p campResponse
		@camps = campResponse.results['items']
		
		# Retrieve the campaign details for the selected campaign
		@campaign = {}		
		camp = ET_Campaign.new
		camp.authStub = session[:authstub]
		camp.props = {'id' => params[:id]}		
		campResponse = camp.get		
		p campResponse
		@campaign['details'] = campResponse.results
				
		# Retrieve the assets related to the selected campaign
		campAsset = ET_Campaign::Asset.new
		campAsset.authStub = session[:authstub]
		campAsset.props = {'id' => params[:id]}		
		assetResponse = campAsset.get
		p assetResponse		
		@campaign['assets'] = assetResponse.results['entities']
		
		haml :'pages/get_campaign'
	end	
	
	## 4 . Provide endpoints to get available asset items for LIST and EMAIL
	get '/assets/:type' do
		getObj = {}

		if params[:type] == "list" then 
			#Get All of the Lists
			getObj = ET_List.new()
			getObj.props = ["ID","ListName"]				
		elsif params[:type] == "email"		
			#Get All of the Emails
			getObj = ET_Email.new()
			getObj.props = ["ID","Name"]						
		end 

		getObj.authStub = session[:authstub]
		getObjResponse = getObj.get
		p getObjResponse	
		
		getObjResponse.to_json		
	end		
	
	## 5. Endpoints for Ajax POST to create CampaignAssets
	post '/campaignAsset' do
		body = request.body.read
		assetDetails = JSON.parse(body)
		
		requestObject = {}
		requestObject['id'] = assetDetails['CampaignID']
		requestObject['ids'] = [assetDetails['ItemID']]
		requestObject['type'] = assetDetails['Type']
		
		campAsset = ET_Campaign::Asset.new
		campAsset.authStub = session[:authstub]
		campAsset.props = requestObject
		postResponse = campAsset.post	
		p postResponse	
		
		postResponse.to_json		
	end	
  
	get '*' do
		@path = params[:splat]
		if File.exists? "#{File.dirname(__FILE__)}/#{@path}.haml"
			haml :"pages/#{@path}"    
		else  
			haml :'pages/404'   
		end
	end   
  
	error 404 do   
		haml :'pages/404'     
	end
  
end
