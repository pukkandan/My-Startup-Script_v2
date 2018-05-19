stringReplace(haystack,needleArray){
    for searchText,replaceText in needleArray
        haystack:=StrReplace(haystack, searchText, replaceText)
    return haystack
}