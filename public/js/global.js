$(document).ready(function(){		

	$('#typeDropDown').combobox()
	$('#itemDropDown').combobox('disable')
	$('#saveCampaignAsset').addClass('disabled')
	
	// Populate the Items once a type has been selected
	$('#typeDropDown').live('changed', function (evt, data) {
		$.ajax({url: '/assets/' + data.text.toLowerCase(),
			type: 'get',		
			dataType: 'json'		
			}).done(function(json){
			if (json.status)
			{
				console.log(json)
				$('#itemDropDown').combobox('enable')
				// Clear out the current list if something was previously selected
				$('#itemList').html('');
				// Update the list of existing campaign assets
				$.each(json.results ,function(index, value) {					
					if (data.text == "EMAIL"){
						$('#itemList').append("<li data-value=\"" + value.id + "\"><a href=\"#\">" + value.name + "</a></li>")												
					} else if (data.text == "LIST"){
						$('#itemList').append("<li data-value=\"" + value.id + "\"><a href=\"#\">" + value.list_name + "</a></li>")	
					}					
				});	
				
			} 			
		});			
	});
	
	// Enable the Add Button once a value has been selected for Item
	$('#itemDropDown').live('changed', function (evt, data) {
		$('#saveCampaignAsset').removeClass('disabled')
	});	
	
	// Process Add Button for adding Campaign Asset
	$('#saveCampaignAsset').on('click',function(){
		var type = $('#typeDropDown').combobox('selectedItem')
		var item = $('#itemDropDown').combobox('selectedItem')
		
		var assetDetails = {}			
		assetDetails['CampaignID'] = $('#campaignid').text()
		assetDetails['ItemID'] = item.value
		assetDetails['Type'] = type.text
		
		$.ajax({url: '/campaignAsset',
			type: 'post',
			data: JSON.stringify(assetDetails),
			dataType: 'json'		
			}).done(function(json){
			if (json.status)
			{
				console.log(json.results[0])		
				console.log(json.results[0].itemID)				
				$('#assetList').append("<li><span class=\"span3\"><h3><strong class=\"muted\">Type: </strong>"+ json.results[0].type +"</h3></span><span class=\"span3\"><h3><strong class=\"muted\">Asset ID: </strong>"+ json.results[0].itemID +"</h3></span><span class=\"span3\"><h3><strong class=\"muted\">Created Date: </strong>"+ json.results[0].createdDate.substring(0,10) +"</h3></span></li>")			
			} 				
		});		
	});	
});

