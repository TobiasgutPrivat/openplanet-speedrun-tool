class ClubCampaignsSelectSWTab : CampaignListSWTab
{
    string t_search;
    uint64 t_typingStart;
    int request = 50;
    int pageSize = 50;
    bool moreavailable = true;

    string GetLabel() override { return Icons::Cubes + " Club Campaigns"; }

    vec4 GetColor() override { return vec4(0.57, 0.61, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayPublicClubCampaign(); }

    void Load() override {
        if (campaigns.Length >= request) return;
        string requestedSearch = t_search;
        auto json = API::CallLiveApiPath("/api/token/club/campaign?length="+pageSize+"&offset="+campaigns.Length+"&name="+t_search);
        if (requestedSearch != t_search) {
            // Search term changed while we were loading
            return;
        }
        Json::Value items = json["clubCampaignList"];
        moreavailable = items.Length == pageSize;
        for (uint i = 0; i < items.Length; i++) {
        // Json::ToFile(IO::FromStorageFolder(i + "temp.json"),items);
            items[i]["playlist"] = items[i]["campaign"]["playlist"];
            CampaignSummary@ campaign = CampaignSummary(items[i]);
            campaigns.InsertLast(campaign);
        }
    }

    void RenderHeader() override
    {
        UI::Text("Search:");
        UI::SameLine();
        bool changed = false;
        t_search = UI::InputText("###Search", t_search, changed);
        if (changed) {
            if (t_search.Length > 1 || t_search.Length == 0) {
                Clear();
                t_typingStart = Time::Now;
            }
        }
        UI::SameLine();
    }
    
    void RenderEnd() override
    {
        if (ShowLoadMore() && moreavailable && UI::GreenButton("Load more")){
            request += pageSize;
        }
    }
}