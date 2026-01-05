class OfficialCampaignsSelectSWTab : CampaignListSWTab
{
    bool ShowLoadMore() override { return false; }

    string GetLabel() override { return Icons::Globe + " Seasonal Campaigns"; }

    vec4 GetColor() override { return vec4(0.6, 0.43, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialQuarterlyCampaign(); }

    void Load() override{
        if (campaigns.Length > 0) return;
        auto json = API::CallLiveApiPath("/api/campaign/official?length=9999");
        Json::Value items = json["campaignList"];
        for (uint i = 0; i < items.Length; i++) {
            items[i]["type"] = "Season";
            items[i]["clubid"] = 0;
            CampaignSummary@ campaign = CampaignSummary(items[i]);
            if (campaign.type == Campaigns::campaignType::Season) {
                // Show past campaigns if the user has permissions
                if (i > 0 && Permissions::PlayPastOfficialQuarterlyCampaign())
                    campaigns.InsertLast(campaign);
                else if (i == 0)
                    campaigns.InsertLast(campaign);
            }
        }
    }
}