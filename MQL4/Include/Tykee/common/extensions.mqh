
 string stringListToJson(string &list[]) {
    if (ArraySize(list) == 0) return "[]";
    CJAVal json;
    for (int i = 0;i < ArraySize(list); i++) {
        json.Add(list[i]);
    }
    return json.Serialize();
}
