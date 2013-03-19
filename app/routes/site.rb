class Main < Sinatra::Base
	
	get '/login' do
		if !session.has_key?(:authstub) then
			session[:authstub] = ET_Client.new
		end
		redirect '/'
	end	
	
	## 1. Display Create Campaign Form with Left Nav
	get '/' do		
		# Retrieve the campaigns for the left nav
		camp = ET_Campaign.new
		camp.authStub = session[:authstub]		
		campResponse = camp.get
		#p campResponse
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
