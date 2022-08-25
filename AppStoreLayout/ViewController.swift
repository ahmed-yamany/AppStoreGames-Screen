
import UIKit

class ViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: Section Definitions
    enum Section: Hashable {
        case promoted
        case standard(String)
        case categories
    }
    
    // MARK: Properties
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var sections = [Section]()
    
    enum SupplementaryViewKind {
        static let header = "header"
        static let topLine = "topLine"
        static let bottomLine = "bottomLine"
    }
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Collection View Setup
        
        collectionView.collectionViewLayout = createSectionsLayout()
        // To display promoted items, you'll need to register PromotedAppCollectionViewCell with the collection view and then configure the data source to return that cell for items in the section.”
        collectionView.register(PromotedAppCollectionViewCell.self, forCellWithReuseIdentifier: PromotedAppCollectionViewCell.reuseIdentifier)
        collectionView.register(StandardAppCollectionViewCell.self, forCellWithReuseIdentifier: StandardAppCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        // registere supplementary Views
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.topLine, withReuseIdentifier: LineView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.bottomLine, withReuseIdentifier: LineView.reuseIdentifier)
      
        configureDataSource()
    }
    
    func createSectionsLayout() -> UICollectionViewLayout {
        // MARK: - Sections Layout
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let section = self.sections[sectionIndex]
            switch section{
            case .promoted:
                // MARK: - Promoted Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section  = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                let headerLine = self.addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: .estimated(1 / UIScreen.main.scale), alignment: .top, supplenentaryKind: SupplementaryViewKind.topLine)
                
                section.boundarySupplementaryItems = [headerLine]
                return section
            case .standard:
                // MARK: - Standard Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(250))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                let headerItem = self.addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: .estimated(44), alignment: .top, supplenentaryKind: SupplementaryViewKind.header)

//                let headerLine = self.addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: .absolute(1 / UIScreen.main.scale), alignment: .topLeading, supplenentaryKind: SupplementaryViewKind.topLine)

                let bottomLine = self.addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: .absolute(1 / UIScreen.main.scale), alignment: .bottom, supplenentaryKind: SupplementaryViewKind.bottomLine)
                
                
                section.boundarySupplementaryItems = [headerItem, bottomLine]

                return section
            case .categories:
                // MARK: - Categories Section Layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // The available layout width can be obtained using the expression
                let availableLayoutWidth = layoutEnvironment.container.effectiveContentSize.width
                let groupWidth = availableLayoutWidth * 0.92
                let remaingWidth = availableLayoutWidth - groupWidth
                let halfOfRemaingWidth = remaingWidth / 2
                let nonCategorySectionItemInset = CGFloat(4)
                let itemLeadingAndTrailing = halfOfRemaingWidth + nonCategorySectionItemInset
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemLeadingAndTrailing, bottom: 0, trailing: itemLeadingAndTrailing)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                let headerItem = self.addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: .estimated(44), alignment: .top, supplenentaryKind: SupplementaryViewKind.header)
                
                section.boundarySupplementaryItems = [headerItem]

                return section
            }
        }
        return layout
    }
    
    func addSupplenentaryItemToSectionLayout(HeaderSizeheightDimensions: NSCollectionLayoutDimension, alignment: NSRectAlignment, supplenentaryKind: String) -> NSCollectionLayoutBoundarySupplementaryItem{
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: HeaderSizeheightDimensions)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: supplenentaryKind, alignment: alignment)
        headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        return headerItem
    }
    
    // MARK: Configure Data Source
    func configureDataSource() {
        dataSourceInitialization()
        supplementaryViewProfider()

        // MARK: SnapShot Definition
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        // append promoted section and it's items
        let popularSection = Section.standard("Popular this week")
        let essentialSection = Section.standard("Essential picks")
        
        snapshot.appendSections([.promoted, popularSection, essentialSection, .categories])
        snapshot.appendItems(Item.promotedApps, toSection: .promoted)
        snapshot.appendItems(Item.popularApps, toSection: popularSection)
        snapshot.appendItems(Item.essentialApps, toSection: essentialSection)
        snapshot.appendItems(Item.categories, toSection: .categories)
        
        
        sections = snapshot.sectionIdentifiers
        dataSource.apply(snapshot)


    }
    
    // MARK: Data Source initialization
    func dataSourceInitialization(){
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell in
            let section = self.sections[indexPath.section]
            switch section{
                
            case .promoted:
                // MARK: - Promoted Section item
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PromotedAppCollectionViewCell.reuseIdentifier, for: indexPath) as! PromotedAppCollectionViewCell
                
                if let app = itemIdentifier.app{
                    cell.configureCell(app)
                }
                return cell
            case .standard:
                // MARK: - Standard Section item
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StandardAppCollectionViewCell.reuseIdentifier, for: indexPath) as! StandardAppCollectionViewCell
                if let app = itemIdentifier.app{
                    let  isThirdItem = (indexPath.row + 1).isMultiple(of: 3)
                    cell.configureCell(app, hideBottomLine: isThirdItem)
                }
                return cell
            case .categories:
                // MARK: - Categories Section item
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
                if let category = itemIdentifier.category{
                    cell.configureCell(category, hideBottomLine: false)
                }
                
                return cell
            
            }
        })
                
    }
    
    // MARK: Supplementary View Provider”
    func supplementaryViewProfider(){
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            switch kind{
            case SupplementaryViewKind.header:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
                
                let section = self.sections[indexPath.section]
                let sectionName: String!
                switch section{
                case .promoted:
                    sectionName = nil
                case .standard(let name):
                    sectionName = name
                case .categories:
                    sectionName = "Top Categories"
                }
                headerView.setTitle(sectionName)
                return headerView
            default:
                let lineView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LineView.reuseIdentifier, for: indexPath) as! LineView
                return lineView
            }
        }
    }
    
}



