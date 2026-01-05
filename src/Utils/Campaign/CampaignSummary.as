class CampaignSummary
{
    int id;
    int clubid;
    bool official;
    string name;
    int mapcount;
    string typeStr;
    Campaigns::campaignType type;
    string[] mapUids;

    CampaignSummary(const Json::Value &in json)
    {
        id = json["id"];
        clubid = json["clubid"];
        name = json["name"];
        mapcount = (json.HasKey("mapcount") && json["mapcount"].GetType() != Json::Type::Null) ? json["mapcount"] : json["playlist"].Length;
        if (json.HasKey("type") && json["type"].GetType() != Json::Type::Null) typeStr = json["type"];
        if (json.HasKey("playlist") && json["playlist"].GetType() != Json::Type::Null) {
            for (uint i = 0; i < json["playlist"].Length; i++) {
                mapUids.InsertLast(json["playlist"][i]["mapUid"]);
            }
        }
        else typeStr = "Unknown";

        // Parse type from tmio API (depending of the club id)
        if (typeStr == "Unknown")
        {
            if (clubid == 0) typeStr = "Season";
            else typeStr = "Club";
        }

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