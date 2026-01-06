class CampaignSummary
{
    int id;
    // int clubid;
    string name;
    // int mapcount;
    string typeStr;
    Campaigns::campaignType type;
    Json::Value mapUids;

    CampaignSummary(const Json::Value &in json)
    {
        id = json["id"];
        name = json["name"];
        if (json.HasKey("mapUids") && json["mapUids"].GetType() != Json::Type::Null) mapUids = json["mapUids"];
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
        json["name"] = name;
        json["type"] = tostring(type);
        json["playlist"] = Json::Array(); //TODO simplify
        for (uint i = 0; i < mapUids.Length; i++) {
            json["playlist"][i] = Json::Object();
            json["playlist"][i]["mapUid"] = mapUids[i];
        }
        return json;
    }
}