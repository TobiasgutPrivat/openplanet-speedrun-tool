class TOTDSelectSWTab : CampaignListSWTab
{

    TOTDSelectSWTab() {}

    string GetLabel() override { return Icons::Calendar + " Tracks of The Day"; }

    vec4 GetColor() override { return vec4(0.217, 0.569, 0.61, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialMonthlyCampaign(); }

    array<string> monthStrings = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

    string GetMonthName(int month)
    {
        if (month == 0 || month > 12)
            return "Invalid month";

        return monthStrings[month - 1];
    }

    void Load() override {
        if (campaigns.Length >= request || !moreavailable) return;
        auto result = API::CallLiveApiPath("/api/token/campaign/month?length="+pageSize+"&offset="+campaigns.Length);
        auto items = result["monthList"];
        moreavailable = items.Length == pageSize;
        
        for(int i = 1; i < items.Length; i++) {//ignore index 0, because we can't speedrun the current TOTD month
            auto json = Json::Object();
            json["id"] = (items[i]["year"] - 2020) * 12 + items[i]["month"];
            json["name"] = GetMonthName(items[i]["month"]) + " " + Json::Write(items[i]["year"]);
            json["type"] = "TOTD";
            json["mapUids"] = Json::Array();
            for (uint j = 0; j < items[i]["days"].Length; j++) {
                json["mapUids"].Add(items[i]["days"][j]["mapUid"]);
            }
            CampaignSummary@ totd = CampaignSummary(json);
            if (i > 0 && Permissions::PlayPastOfficialMonthlyCampaign())
                campaigns.InsertLast(totd);
            else if (i == 0)
                campaigns.InsertLast(totd);
        }
    }
}