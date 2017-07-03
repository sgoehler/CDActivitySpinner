Pod::Spec.new do |s|
  s.name     = 'CDActivitySpinner'
  s.version  = '1.0.7'
  s.license     = { :type => 'Apache License, Version 2.0',
                    :text => <<-LICENSE
                      Copyright (c) 2010 Google Inc.
                      Licensed under the Apache License, Version 2.0 (the "License");
                      you may not use this file except in compliance with the License.
                      You may obtain a copy of the License at
                        http://www.apache.org/licenses/LICENSE-2.0
                      Unless required by applicable law or agreed to in writing, software
                      distributed under the License is distributed on an "AS IS" BASIS,
                      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                      See the License for the specific language governing permissions and
                      limitations under the License.
                    LICENSE
  } 
  s.platform = :ios
  s.summary  = 'Round open gap activity spinner with additional progress functionality'
  s.homepage = 'https://github.com/sgoehler/CDActivitySpinner'
  s.authors  = { 'Stefan Goehler' => 'mail@stefan-goehler.de' }
  s.source   = { 
	:git => 'https://github.com/sgoehler/CDActivitySpinner.git', 	:tag => '1.0.7'
  }
  s.source_files = 'Sources/*.{h,m}'
  s.frameworks   = ['QuartzCore']

  s.requires_arc = true
end
