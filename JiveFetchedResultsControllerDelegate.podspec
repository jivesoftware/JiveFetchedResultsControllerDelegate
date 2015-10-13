Pod::Spec.new do |s|
  s.name = 'JiveFetchedResultsControllerDelegate'
  s.version = '0.1.0'
  s.license = { :type => 'CC', :file => 'LICENSE' }
  s.summary = 'JiveFetchedResultsControllerDelegate integrates NSFetchedResultsController and UITableView'
  s.homepage = 'https://github.com/jivesoftware/JiveFetchedResultsControllerDelegate'
  s.social_media_url = 'http://twitter.com/JiveSoftware'
  s.authors = { 'Jive Mobile' => 'jive-mobile@jivesoftware.com' }
  s.source = { :git => 'https://github.com/jivesoftware/JiveFetchedResultsControllerDelegate.git', :tag => s.version }

  s.ios.deployment_target = '8.1'

  s.requires_arc = true
  s.source_files = 'Source/JiveFetchedResultsControllerDelegate/*.{h,m}'
  s.framework = 'CoreData'
  s.framework = 'UIKit'

end
