# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'date'
require 'google/apis/core/base_service'
require 'google/apis/core/json_representation'
require 'google/apis/core/hashable'
require 'google/apis/errors'

module Google
  module Apis
    module AbusiveexperiencereportV1
      
      # Response message for GetSiteSummary.
      # Do not confuse with same message in google.ads.experiencereport.v1
      class SiteSummaryResponse
        include Google::Apis::Core::Hashable
      
        # The status of the site reviewed for the abusive experiences.
        # Corresponds to the JSON property `abusiveStatus`
        # @return [String]
        attr_accessor :abusive_status
      
        # The date on which enforcement begins.
        # Corresponds to the JSON property `enforcementTime`
        # @return [String]
        attr_accessor :enforcement_time
      
        # The abusive experience enforcement status of the site.
        # Corresponds to the JSON property `filterStatus`
        # @return [String]
        attr_accessor :filter_status
      
        # The last time that the site changed status.
        # Corresponds to the JSON property `lastChangeTime`
        # @return [String]
        attr_accessor :last_change_time
      
        # A link that leads to a full abusive experience report.
        # Corresponds to the JSON property `reportUrl`
        # @return [String]
        attr_accessor :report_url
      
        # The name of the site reviewed.
        # Corresponds to the JSON property `reviewedSite`
        # @return [String]
        attr_accessor :reviewed_site
      
        # Whether the site is currently under review.
        # Corresponds to the JSON property `underReview`
        # @return [Boolean]
        attr_accessor :under_review
        alias_method :under_review?, :under_review
      
        def initialize(**args)
           update!(**args)
        end
      
        # Update properties of this object
        def update!(**args)
          @abusive_status = args[:abusive_status] if args.key?(:abusive_status)
          @enforcement_time = args[:enforcement_time] if args.key?(:enforcement_time)
          @filter_status = args[:filter_status] if args.key?(:filter_status)
          @last_change_time = args[:last_change_time] if args.key?(:last_change_time)
          @report_url = args[:report_url] if args.key?(:report_url)
          @reviewed_site = args[:reviewed_site] if args.key?(:reviewed_site)
          @under_review = args[:under_review] if args.key?(:under_review)
        end
      end
      
      # Response message for ListViolatingSites.
      class ViolatingSitesResponse
        include Google::Apis::Core::Hashable
      
        # A list of summaries of violating sites.
        # Corresponds to the JSON property `violatingSites`
        # @return [Array<Google::Apis::AbusiveexperiencereportV1::SiteSummaryResponse>]
        attr_accessor :violating_sites
      
        def initialize(**args)
           update!(**args)
        end
      
        # Update properties of this object
        def update!(**args)
          @violating_sites = args[:violating_sites] if args.key?(:violating_sites)
        end
      end
    end
  end
end
