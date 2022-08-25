
import UIKit

class ViewController: UIViewController {
        
    // MARK: Section Definitions
    enum Section: Hashable {
        case promoted
        case standard(String)
        case categories
    }

    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Collection View Setup
        collectionView.collectionViewLayout = createSectionsLayout()
        // To display promoted items, you'll need to register PromotedAppCollectionViewCell with the collection view and then configure the data source to return that cell for items in the section.”
        collectionView.register(PromotedAppCollectionViewCell.self, forCellWithReuseIdentifier: PromotedAppCollectionViewCell.reuseIdentifier)
        collectionView.register(StandardAppCollectionViewCell.self, forCellWithReuseIdentifier: StandardAppCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        
        configureDataSource()
    }
    
    func createSectionsLayout() -> UICollectionViewLayout {
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
                
                return section
                
            
            }
            
        }
        
        return layout
    }

    func configureDataSource() {
        // MARK: Data Source initialization
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
        }
        )
        
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
}

