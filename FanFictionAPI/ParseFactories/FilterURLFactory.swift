//
//  FilterURLFactory.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation

internal class FilterURLFactory {
    
    /// Create the url parameters for a filter url
    /// - Parameter selections: the user's selected filters to apply
    /// - Parameter fandom: name of the fandom to search on
    /// - Returns: the url parameters
    internal static func create(from selections: FilterSelections, fandom: String) -> String {
        var parameters = ""
        
        // Include tags parameters
        parameters += FilterURLFactory.createTagParameters(from: selections.includeTags, isInclude: true)
        
        // Exclude tags parameters
        parameters += parameters.isEmpty ? "" : "&"
        parameters += FilterURLFactory.createTagParameters(from: selections.excludeTags, isInclude: false)
        
        // Sorting parameters
        parameters += parameters.isEmpty ? "" : "&"
        parameters += FilterURLFactory.createSortingParameters(from: selections.sorting)
        
        // Assorted parameters
        parameters += "&" + Constants.commitAndSort
        parameters += "&" + Category.fandom.rawValue + "=" + fandom.replacingOccurrences(of: " ", with: "+").webFriendly()
        
        return Constants.base + parameters
    }
}
 
// MARK: Sorting
extension FilterURLFactory {
    private static func createSortingParameters(from sorting: FilterSelections.Sorting) -> String {
        var parameters = ""
        
        let sort = Sort(sorting.sort.display)
        parameters = Keys.createParameter(keyValue: Keys.sortKey, selection: sort.rawValue)
        
        // Not supported
        parameters += "&" + Keys.createParameter(keyValue: Keys.otherTagsKey, selection: "")
        parameters += "&" + Keys.createParameter(keyValue: Keys.excludeTagsKey, selection: "")
        
        parameters += "&" + Keys.createParameter(keyValue: Keys.crossoverKey, selection: Crossover(sorting.crossover.display).rawValue)
        parameters += "&" + Keys.createParameter(keyValue: Keys.completeKey,  selection: Completion(sorting.complete.display).rawValue)
        
        parameters += "&" + translateWordCountRange(from: sorting.wordCountRange)
        
        parameters += "&" + translateDateRange(from: sorting.dateRange)
        
        parameters += "&" + Keys.createParameter(keyValue: Keys.queryKey, selection: "")
        
        if let languageIndex = sorting.language.options.firstIndex(where: { $0.name == sorting.language.display }) {
            let language = sorting.language.options[languageIndex].id
            parameters += "&" + Keys.createParameter(keyValue: Keys.languageKey, selection: language)
        }
        
        return parameters
    }
    
    private static func translateWordCountRange(from dateRange: FilterSelections.Sorting.SliderRange) -> String {
        var datesParameter = ""
        
        let lowRange = dateRange.rangeValues[dateRange.selectedRange.lowerBound]
        if let lowKey = FilterURLFactory.formatDateRange(for: Keys.wordCountRangeLowKey, selectedRange: lowRange) {
            datesParameter = lowKey
        }
        
        let highRange = dateRange.rangeValues[dateRange.selectedRange.upperBound]
        if let highKey = FilterURLFactory.formatDateRange(for: Keys.wordCountRangeHighKey, selectedRange: highRange) {
            datesParameter += "&"
            datesParameter += highKey
        }
        
        return datesParameter
    }
    
    private static func formatWordCountRange(for rangeKey: String, selectedRange: String) -> String? {
        let countFormattedKey = FilterSelections.Sorting.Options.WordCount(rawValue: selectedRange)
        let countFormatted = countFormattedKey?.translateToNumber()
        
        return Keys.createParameter(keyValue: rangeKey, selection: countFormatted ?? "")
    }
    
    private static func translateDateRange(from dateRange: FilterSelections.Sorting.SliderRange) -> String {
        var datesParameter = ""
        
        let lowRange = dateRange.rangeValues[dateRange.selectedRange.lowerBound]
        if let lowKey = FilterURLFactory.formatDateRange(for: Keys.dateRangeLowKey, selectedRange: lowRange) {
            datesParameter = lowKey
        }
        
        let highRange = dateRange.rangeValues[dateRange.selectedRange.upperBound]
        if let highKey = FilterURLFactory.formatDateRange(for: Keys.dateRangeHighKey, selectedRange: highRange) {
            datesParameter += "&"
            datesParameter += highKey
        }
        
        return datesParameter
    }
    
    private static func formatDateRange(for rangeKey: String, selectedRange: String) -> String? {
        let dateFormattedKey = FilterSelections.Sorting.Options.DateRange(rawValue: selectedRange)
        let dateFormatted = dateFormattedKey?.translateToDate()
        
        return Keys.createParameter(keyValue: rangeKey, selection: dateFormatted ?? "")
    }
}
 
// MARK: Include/ Exclude Tags
extension FilterURLFactory {
    private static func createTagParameters(from sorting: FilterSelections.Tags, isInclude: Bool) -> String {
        var parameters = ""
        
        parameters += getParameters(from: sorting.ratings, parameterKey: IncludeExcludeKeys.ratings, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.warnings, parameterKey: IncludeExcludeKeys.warnings, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.categories, parameterKey: IncludeExcludeKeys.categories, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.fandoms, parameterKey: IncludeExcludeKeys.fandoms, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.characters, parameterKey: IncludeExcludeKeys.categories, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.relationships, parameterKey: IncludeExcludeKeys.relationships, isInclude: isInclude)
        
        parameters += getIncludeJoiner(parameters)
        parameters += getParameters(from: sorting.additionalTags, parameterKey: IncludeExcludeKeys.additionalTags, isInclude: isInclude)
        
        return parameters
    }
    
    private static func getIncludeJoiner(_ parameters: String) -> String {
        guard !parameters.isEmpty else { return "" }
        
        if parameters.last != "&" {
            return "&"
        }
        
        return ""
    }
    
    //    exclude_work_search %5B freeform_ids %5D%5B%5D = 76147 &
    private static func getParameters(from tagGroup: FilterSelections.Tags.Options, parameterKey: String, isInclude: Bool) -> String {
        var parameters = ""
        let inclusionKey = isInclude ? Inclusion.include.rawValue : Inclusion.exclude.rawValue
        
        for option in tagGroup.options {
            if option.isSelected {
                let parameter: String = inclusionKey + Constants.joiner + parameterKey + Constants.inclusionJoiner + "="
                parameters += parameters.isEmpty ? "" : "&"
                parameters += parameter + option.filterInfo.id
            }
        }
        
        return parameters
    }
}

// MARK: Filter Keys
extension FilterURLFactory {
    
    public enum Keys {
        static let sortKey = "sort_column"
        static let otherTagsKey = "other_tag_names"
        static let excludeTagsKey = "excluded_tag_names"
        static let crossoverKey = "crossover"
        static let completeKey = "complete"
        static let wordCountRangeLowKey = "words_from"
        static let wordCountRangeHighKey = "words_to"
        static let dateRangeLowKey = "date_from"
        static let dateRangeHighKey = "date_to"
        static let queryKey = "query"
        static let languageKey = "language_id"
        
        static func createParameter(keyValue: String, selection: String) -> String {
            Constants.searchKey + Constants.joiner + keyValue + Constants.joiner + "=" + selection
        }
    }
    
    public enum IncludeExcludeKeys {
        static let ratings = "rating_ids"
        static let warnings = "archive_warning_ids"
        static let categories = "category_ids"
        static let fandoms = "fandom_ids"
        static let characters = "character_ids"
        static let relationships = "relationship_ids"
        static let additionalTags = "freeform_ids"
    }
    
    public enum Inclusion: String {
        case include = "include_work_search"
        case exclude = "exclude_work_search"
        case none = ""
    }
    
    public enum Category: String {
        case user = "user_id"
        case fandom = "tag_id"
    }
    
    public enum Sort: String {
        // Time (newest to oldest)
        case created = "created_at"
        case updated = "revised_at"
        
        // Work Info (alphabetical)
        case author = "authors_to_sort_on"
        case title = "title_to_sort_on"
        
        // Work Stats (highest to lowest)
        case wordCount = "word_count"
        case hits = "hits"
        case kudos = "kudos_count"
        case comments = "comments_count"
        case bookmarks = "bookmarks_count"
        
        init(_ sorting: String) {
            guard let sortingOption = FilterSelections.Sorting.Options.Sorting(rawValue: sorting) else {
                self = .updated
                return
            }
            
            switch sortingOption {
                case .dateUpdated:
                    self = .updated
                case .dateCreated:
                    self = .created
                case .author:
                    self = .author
                case .title:
                    self = .title
                case .wordcount:
                    self = .wordCount
                case .hits:
                    self = .hits
                case .kudos:
                    self = .kudos
                case .comments:
                    self = .comments
                case .bookmarks:
                    self = .bookmarks
            }
        }
    }
    
    public enum Crossover: String {
        case include = ""
        case exclude = "F"
        case showOnlyCrossovers = "T"
        
        init(_ crossover: String) {
            guard let crossoverOption = FilterSelections.Sorting.Options.Crossover(rawValue: crossover) else {
                self = .include
                return
            }
            
            switch crossoverOption {
                case .includeCrossovers:
                    self = .include
                case .excludeCrossovers:
                    self = .exclude
                case .onlyCrossovers:
                    self = .showOnlyCrossovers
            }
        }
    }
    
    public enum Completion: String {
        case complete = "T"
        case inProgress = "F"
        case any = ""
        
        init(_ completion: String) {
            guard let completionOption = FilterSelections.Sorting.Options.Completion(rawValue: completion) else {
                self = .any
                return
            }
            
            switch completionOption {
                case .completeWorks:
                    self = .complete
                case .allWorks:
                    self = .any
                case .inProgressWorks:
                    self = .inProgress
            }
        }
    }
    
    private enum Constants {
        static let base = "https://archiveofourown.org/works?"
        static let commitAndSort = "commit=Sort+and+Filter"
        static let searchKey = "work_search"
        static let joiner = "%5D"
        static let inclusionJoiner = "%5D%5B%5D"
    }
    
    // Search string
    
    //https://archiveofourown.org/works?
    //commit=Sort+and+Filter&
    //work_search%5Bsort_column%5D=revised_at&
    //include_work_search%5Barchive_warning_ids%5D%5B%5D=17&
    //include_work_search%5Barchive_warning_ids%5D%5B%5D=20&
    //include_work_search%5Barchive_warning_ids%5D%5B%5D=14&
    //work_search%5Bother_tag_names%5D=&
    //work_search%5Bexcluded_tag_names%5D=&
    //work_search%5Bcrossover%5D=&
    //work_search%5Bcomplete%5D=&
    //work_search%5Bwords_from%5D=&
    //work_search%5Bwords_to%5D=&
    //work_search%5Bdate_from%5D=&
    //work_search%5Bdate_to%5D=&
    //work_search%5Bquery%5D=&
    //work_search%5Blanguage_id%5D=&
    //tag_id=Naruto&
    //user_id=LydiaClairvoyanne

    //https://archiveofourown.org/works?
    //work_search%5Bsort_column%5D=revised_at&
    //work_search%5Bother_tag_names%5D=&
    //work_search%5Bexcluded_tag_names%5D=&
    //work_search%5Bcrossover%5D=&
    //work_search%5Bcomplete%5D=&
    //work_search%5Bwords_from%5D=&
    //work_search%5Bwords_to%5D=&
    //work_search%5Bdate_from%5D=2023-04-03&
    //work_search%5Bdate_to%5D=2023-05-31&
    //work_search%5Bquery%5D=&
    //work_search%5Blanguage_id%5D=&
    //commit=Sort+and+Filter&
    //tag_id=Naruto&user_id=LydiaClairvoyanne
// https://archiveofourown.org/works?work_search%5Bsort_column%5D=revised_at&work_search%5Bother_tag_names%5D=&work_search%5Bexcluded_tag_names%5D=&work_search%5Bcrossover%5D=F&work_search%5Bcomplete%5D=&work_search%5Bwords_from%5D=&work_search%5Bwords_to%5D=&work_search%5Bdate_from%5D=2023-04-03&work_search%5Bdate_to%5D=2023-05-31&work_search%5Bquery%5D=&work_search%5Blanguage_id%5D=&commit=Sort+and+Filter&tag_id=Naruto&user_id=LydiaClairvoyanne
// https://archiveofourown.org/works?commit=Sort+and+Filter&
    //work_search%5Bsort_column%5D=revised_at&work_search%5Bother_tag_names%5D=&work_search%5Bexcluded_tag_names%5D=&work_search%5Bcrossover%5D=&work_search%5Bcomplete%5D=T&work_search%5Bwords_from%5D=&work_search%5Bwords_to%5D=&work_search%5Bdate_from%5D=&work_search%5Bdate_to%5D=&work_search%5Bquery%5D=&work_search%5Blanguage_id%5D=&tag_id=Naruto&user_id=LydiaClairvoyanne
    
    // https://archiveofourown.org/works?commit=Sort+and+Filter&
    //work_search%5Bsort_column%5D=revised_at&work_search%5Bother_tag_names%5D=&work_search%5Bexcluded_tag_names%5D=&work_search%5Bcrossover%5D=&work_search%5Bcomplete%5D=&work_search%5Bwords_from%5D=&work_search%5Bwords_to%5D=&work_search%5Bdate_from%5D=&work_search%5Bdate_to%5D=&work_search%5Bquery%5D=&work_search%5Blanguage_id%5D=&tag_id=Naruto
    
//                    https://archiveofourown.org/works?commit=Sort+and+Filter&
//
//                    work_search%5Bsort_column%5D=revised_at&                  sort by newest
//                    include_work_search%5Bcharacter_ids%5D%5B%5D=748&         has character (John Lennon)
//
//                    other_tag_names
//                    excluded_tag_names
//                    crossover
//                    complete
//                    words_from
//                    words_to
//                    date_from
//                    date_to
//                    query
//                    language_id
//
//                    user_id=oh_johnny
    
//                https://archiveofourown.org/works?
//                    commit=Sort+and+Filter&
//                    work_search%5Bsort_column%5D=revised_at&
//                    include_work_search%5Brating_ids%5D%5B%5D=13&
//                    include_work_search%5Bcharacter_ids%5D%5B%5D=748&
//                    work_search%5Bother_tag_names%5D=&
//                    exclude_work_search%5Brating_ids%5D%5B%5D=10&
//                    work_search%5Bexcluded_tag_names%5D=&
//                    work_search%5Bcrossover%5D=&
//                    work_search%5Bcomplete%5D=&
//                    work_search%5Bwords_from%5D=&
//                    work_search%5Bwords_to%5D=&
//                    work_search%5Bdate_from%5D=&
//                    work_search%5Bdate_to%5D=&
//                    work_search%5Bquery%5D=&
//                    work_search%5Blanguage_id%5D=&
    
//                    user_id=oh_johnny
}
