//
//  GeometryEditViewController.h
//  MAGE
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AnnotationDragCallback.h"
#import "GeometryEditCoordinator.h"
#import "GeometryEditMapDelegate.h"
#import <MaterialComponents/MaterialContainerScheme.h>

@protocol CoordinateFieldListener;

@interface GeometryEditViewController : UIViewController <AnnotationDragCallback, CoordinateFieldListener>

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) BOOL allowsPolygonIntersections;
@property (strong, nonatomic) GeometryEditMapDelegate* mapDelegate;

- (instancetype) initWithCoordinator: (GeometryEditCoordinator *) coordinator scheme: (id<MDCContainerScheming>) containerScheme;
- (void) applyThemeWithContainerScheme:(id<MDCContainerScheming>)containerScheme;
- (BOOL) validate:(NSError **) error;

@end
