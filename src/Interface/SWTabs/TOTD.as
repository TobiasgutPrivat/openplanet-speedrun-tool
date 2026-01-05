class TOTDSelectSWTab : SWTab
{

    array<CampaignSummary@> campaigns;

    TOTDSelectSWTab() {}

    string GetLabel() override { return Icons::Calendar + " Tracks of The Day"; }

    vec4 GetColor() override { return vec4(0.217, 0.569, 0.61, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialMonthlyCampaign(); }

    string GetMonthName(int month)
    {
        const array<string> months = {
            "",          // index 0 unused
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        };

        if (month < 1 || month > 12)
            return "Invalid month";

        return months[month];
    }

    void Load() override {
        auto json = API::CallLiveApiPath("/api/token/campaign/month?length=9999");
        auto months = json["monthList"];
        
        for(int i = 1; i < months.Length; i++) {//ignore index 0, because we can't speedrun the current TOTD month
            months[i]["id"] = (months[i]["year"] - 2020) * 12 + months[i]["month"];
            months[i]["playlist"] = months[i]["days"];
            months[i]["name"] = GetMonthName(months[i]["month"]) + " " + Json::Write(months[i]["year"]);
            months[i]["type"] = "TOTD";
            CampaignSummary@ totd = CampaignSummary(months[i]);

            if (i > 0 && Permissions::PlayPastOfficialMonthlyCampaign())
                campaigns.InsertLast(totd);
            else if (i == 0)
                campaigns.InsertLast(totd);
        }
    }

    void Clear()
    {
        campaigns.RemoveRange(0, campaigns.Length);
    }

    void RenderReloadButton()
    {
        vec2 posOrig = UI::GetCursorPos();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x-40, posOrig.y));
        if (UI::Button(Icons::Refresh))
        {
            Clear();
        }
        UI::SetCursorPos(vec2(posOrig.x, posOrig.y+12));
        UI::NewLine();
    }

    void Render() override
    {
        RenderReloadButton();
        if (campaigns.Length == 0) {
            UI::Text("No campaigns found.");
            return;
        }
        UI::BeginChild("campaignList");
        if (UI::BeginTable("List", 2)) {
            UI::TableSetupScrollFreeze(0, 1);
            PushTabStyle();
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("Select", UI::TableColumnFlags::WidthFixed, 80);
            UI::TableHeadersRow();
            PopTabStyle();

            UI::ListClipper clipper(campaigns.Length);
            while(clipper.Step()) {
                for(int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
                {
                    UI::PushID("CampaignListLine"+i);
                    CampaignSummary@ campaign = campaigns[i];
                    IfaceRender::CampaignListLine(campaign);
                    UI::PopID();
                }
            }
            UI::EndTable();
        }
        UI::EndChild();
    }

}