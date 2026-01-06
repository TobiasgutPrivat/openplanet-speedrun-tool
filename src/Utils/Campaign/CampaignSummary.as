class CampaignSummary
{
    int id;
    int clubid;
    string name;
    int mapcount;
    string typeStr;
    Campaigns::campaignType type;
    string[] mapUids;

    CampaignSummary(const Json::Value &in json)
    {
        id = json["id"];
        name = json["name"];
        if (json.HasKey("clubid") && json["clubid"].GetType() != Json::Type::Null) clubid = json["clubid"];
        if (json.HasKey("mapcount") && json["mapcount"].GetType() != Json::Type::Null) mapcount = json["mapcount"];
        if (json.HasKey("playlist") && json["playlist"].GetType() != Json::Type::Null) {
            //for seasonal/TOTD campaigns
            auto playlist = json["playlist"];
            mapcount = playlist.Length;
            for (uint i = 0; i < json["playlist"].Length; i++) {
                mapUids.InsertLast(json["playlist"][i]["mapUid"]);
            }
        }

        if (json.HasKey("type") && json["type"].GetType() != Json::Type::Null) typeStr = json["type"];
        else typeStr = "Unknown";

        // we need to convert string to enum
        if (typeStr == "Season") type = Campaigns::campaignType::Season;
        else if (typeStr == "Club") type = Campaigns::campaignType::Club;
        else if (typeStr == "Training") type = Campaigns::campaignType::Training;
        else if (typeStr == "TOTD") type = Campaigns::campaignType::TOTD;
        else type = Campaigns::campaignType::Unknown;
    }

    Json::Value ToJson()
    {
        Json::Value json = Json::Object();
        json["id"] = id;
        json["clubid"] = clubid;
        json["name"] = name;
        json["mapcount"] = mapcount;
        json["type"] = tostring(type);
        json["playlist"] = Json::Array(); //TODO simplify
        for (uint i = 0; i < mapUids.Length; i++) {
            json["playlist"][i] = Json::Object();
            json["playlist"][i]["mapUid"] = mapUids[i];
        }
        return json;
    }
}