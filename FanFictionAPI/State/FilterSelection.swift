//
//  FilterSelection.swift
//  
//
//  Created by Natasha Martinez on 2/28/25.
//

import Foundation
import SwiftUI

public class FilterSelections: ObservableObject {
    @Published var sorting: Sorting
    @Published var includeTags: Tags
    @Published var excludeTags: Tags
    
    init(
        sorting: Sorting? = nil,
        includeTags: Tags? = nil,
        excludeTags: Tags? = nil
    ) {
        self.sorting = sorting ?? Sorting()
        self.includeTags = includeTags ?? Tags()
        self.excludeTags = excludeTags ?? Tags()
    }
    
    func loadLanguages(_ languages: [FeedFilterInfo.FilterInfo]) {
        sorting.language.options = languages
    }
}

extension FilterSelections {
    class Sorting: ObservableObject {
        @Published var sort:      DropdownOption
        @Published var language:  DropdownOption
        @Published var crossover: DropdownOption
        @Published var complete:  DropdownOption
        @Published var wordCountRange: SliderRange
        @Published var dateRange:      SliderRange
        
        init(
            sort:      DropdownOption? = nil,
            language:  DropdownOption? = nil,
            crossover: DropdownOption? = nil,
            complete:  DropdownOption? = nil,
            wordCountRange: SliderRange? = nil,
            dateRange:      SliderRange? = nil
        ) {
            self.sort      = sort      ?? DropdownOption(options: Options.Sorting.all)
            self.language  = language  ?? DropdownOption(options: [""])
            self.crossover = crossover ?? DropdownOption(options: Options.Crossover.all)
            self.complete  = complete  ?? DropdownOption(options: Options.Completion.all)
            self.wordCountRange = wordCountRange ?? SliderRange(rangeValues: Options.WordCount.all)
            self.dateRange = dateRange ?? SliderRange(rangeValues: Options.DateRange.all)
        }
    }
}

extension FilterSelections.Sorting {
    class DropdownOption: ObservableObject {
        @Published var display: String
        @Published var options: [FeedFilterInfo.FilterInfo]
        
        init(options: [String]) {
            self.display = options[0]
            self.options = options.map({ FeedFilterInfo.FilterInfo(name: $0, id: $0) })
        }
        
        init(options: [FeedFilterInfo.FilterInfo]) {
            self.display = options[0].name
            self.options = options
        }
    }
    
    class SliderRange: ObservableObject {
        let rangeValues: [String]
        let sliderBounds: ClosedRange<Int>
        @Published var selectedRange: ClosedRange<Int>
        
        init(rangeValues: [String], selectedRange: ClosedRange<Int>? = nil) {
            self.rangeValues = rangeValues
            
            let sliderBounds = ClosedRange(uncheckedBounds: (lower: 0, upper: rangeValues.count - 1))
            self.selectedRange = selectedRange ?? sliderBounds
            self.sliderBounds = sliderBounds
        }
    }
}

extension FilterSelections.Sorting {
    enum Options {
        enum Sorting: String {
            case dateUpdated = "filter.dateUpdated"
            case dateCreated = "filter.dateCreated"
            case author = "filter.author"
            case title = "filter.title"
            case wordcount = "filter.wordcount"
            case hits = "filter.hits"
            case kudos = "filter.kudos"
            case comments = "filter.comments"
            case bookmarks = "filter.bookmarks"
            
            static var all: [String] {
                [
                    Sorting.dateUpdated.rawValue,
                    Sorting.dateCreated.rawValue,
                    Sorting.author.rawValue,
                    Sorting.title.rawValue,
                    Sorting.wordcount.rawValue,
                    Sorting.hits.rawValue,
                    Sorting.kudos.rawValue,
                    Sorting.comments.rawValue,
                    Sorting.bookmarks.rawValue
                ]
            }
        }
        
        enum Crossover: String {
            case includeCrossovers = "Include crossovers"
            case excludeCrossovers = "Exclude crossovers"
            case onlyCrossovers = "Show only crossovers"
            
            static var all: [String] {
                [
                    Crossover.includeCrossovers.rawValue,
                    Crossover.excludeCrossovers.rawValue,
                    Crossover.onlyCrossovers.rawValue
                ]
            }
        }
        
        enum Completion: String {
            case allWorks = "All works"
            case completeWorks = "Complete works only"
            case inProgressWorks = "Works in progress only"
            
            static var all: [String] {
                [
                    Completion.allWorks.rawValue,
                    Completion.completeWorks.rawValue,
                    Completion.inProgressWorks.rawValue
                ]
            }
        }
        
        enum DateRange: String {
            case anyLow = "Any"
            case fiveYears = "5 Years"
            case oneYear = "1 Year"
            case sixMonths = "6 Months"
            case oneMonth = "1 Month"
            case oneWeek = "1 Week"
            case today = "Today"
            
            static var all: [String] {
                [
                    DateRange.anyLow.rawValue,
                    DateRange.fiveYears.rawValue,
                    DateRange.oneYear.rawValue,
                    DateRange.sixMonths.rawValue,
                    DateRange.oneMonth.rawValue,
                    DateRange.oneWeek.rawValue,
                    DateRange.today.rawValue
                ]
            }
            
            /// Translates the enum to a correlating date
            /// - Returns: correlating date in format YYYY-MM-DD
            func translateToDate() -> String? {
                var dateToFormat: Date?
                switch self {
                    case .anyLow:
                        return nil
                    case .fiveYears:
                        dateToFormat = Calendar.current.date(byAdding: .year, value: -5, to: Date())
                    case .oneYear:
                        dateToFormat = Calendar.current.date(byAdding: .year, value: -1, to: Date())
                    case .sixMonths:
                        dateToFormat = Calendar.current.date(byAdding: .month, value: -6, to: Date())
                    case .oneMonth:
                        dateToFormat = Calendar.current.date(byAdding: .month, value: -1, to: Date())
                    case .oneWeek:
                        dateToFormat = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                    case .today:
                        return nil
                }
                
                guard let dateToFormat = dateToFormat else { return nil }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                return dateFormatter.string(from: dateToFormat)
            }
        }
        
        enum WordCount: String {
            case anyLow = "1"
            case oneThousand = "1000"
            case tenThousand = "10k"
            case fiftyThousand = "50k"
            case oneHundredThousand = "100k"
            case fiveHundredThousand = "500k"
            case anyHigh = "Any"
            
            static var all: [String] {
                [
                    WordCount.anyLow.rawValue,
                    WordCount.oneThousand.rawValue,
                    WordCount.tenThousand.rawValue,
                    WordCount.fiftyThousand.rawValue,
                    WordCount.oneHundredThousand.rawValue,
                    WordCount.fiveHundredThousand.rawValue,
                    WordCount.anyHigh.rawValue
                ]
            }
            
            func translateToNumber() -> String {
                switch self {
                    case .anyLow:
                        return ""
                    case .oneThousand:
                        return "1000"
                    case .tenThousand:
                        return "10000"
                    case .fiftyThousand:
                        return "50000"
                    case .oneHundredThousand:
                        return "100000"
                    case .fiveHundredThousand:
                        return "500000"
                    case .anyHigh:
                        return ""
                }
            }
        }
    }
}

extension FilterSelections {
    class Tags: ObservableObject {
        @Published var ratings        = Options()
        @Published var warnings       = Options()
        @Published var categories     = Options()
        @Published var fandoms        = Options()
        @Published var characters     = Options()
        @Published var relationships  = Options()
        @Published var additionalTags = Options()
    }
}

extension FilterSelections.Tags {
    class Options: ObservableObject {
        @Published var options: [Option]
        
        init(options: [Option]? = nil) {
            self.options = options ?? []
        }
        
        func populate(_ newOptions: [FeedFilterInfo.FilterInfo], group: TagsProtocol.Type, filterType: StoryInfo.Filter.FilterType? = nil) {
            guard options.isEmpty else { return }
            options = newOptions.map({
                let tag: TagsProtocol?
                if let filterType = filterType {
                    tag = StoryInfo.Filter(title: $0.name, type: filterType)
                } else {
                    tag = group.init(filter: $0)
                }
                
                return Option(filterInfo: $0, tag: tag)
            })
        }
    }
    
    class Option: ObservableObject, Hashable {
        let filterInfo: FeedFilterInfo.FilterInfo
        private(set) var tag: TagsProtocol? = nil
        @Published var isSelected: Bool
        
        init(filterInfo: FeedFilterInfo.FilterInfo, tag: TagsProtocol? = nil, isSelected: Bool = false) {
            self.filterInfo = filterInfo
            self.tag = tag
            self.isSelected = isSelected
        }
        
        static func == (lhs: FilterSelections.Tags.Option, rhs: FilterSelections.Tags.Option) -> Bool {
            lhs.isSelected == rhs.isSelected && lhs.filterInfo.id == rhs.filterInfo.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(isSelected)
            hasher.combine(filterInfo.name)
        }
    }
}
