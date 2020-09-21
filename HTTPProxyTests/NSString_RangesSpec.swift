@testable import HTTPProxy
import Quick
import Nimble

class NSString_Ranges: QuickSpec {
    override func spec() {
        describe("ranges:") {
            context("Search string is present") {
                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    ("aBCd_&9%$ 99|", "a", [NSRange(location: 0, length: 1)])
                }

                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    ("aBCd_&9%$ 99|", "d_&9%$ ", [NSRange(location: 3, length: 7)])
                }
        
                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    ("aBCd_&9%$ 99|", "99", [NSRange(location: 10, length: 2)])
                }
                
                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    (
                     "aBCd_&9%$ 99|",
                     "9",
                     [NSRange(location: 6, length: 1),
                      NSRange(location: 10, length: 1),
                      NSRange(location: 11, length: 1)]
                    )
                }
                
                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    (
                     "#><W\\s'd <W<*&",
                     "<W",
                     [NSRange(location: 2, length: 2),
                      NSRange(location: 9, length: 2)]
                    )
                }
                
                itBehavesLike(ContainsSearchString.self) { () -> (String, String, [NSRange]) in
                    (
                     "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                     ", sed do eiusmod",
                     [NSRange(location: 55, length: 16)]
                    )
                }
            }
            
            context("Search string is not present") {
                itBehavesLike(DoesNotContainSearchString.self) { () -> (String, String) in
                    ("abcef", "d")
                }
                
                itBehavesLike(DoesNotContainSearchString.self) { () -> (String, String) in
                    ("abcef", "ac")
                }
                
                itBehavesLike(DoesNotContainSearchString.self) { () -> (String, String) in
                    ("abcef", " abc")
                }
            }
        }
    }
}

private class ContainsSearchString: Behavior<(String, String, [NSRange])> {
    override class func spec(_ context: @escaping () -> (String, String, [NSRange])) {
        
        var sut: String!
        var searchString: String!
        var expectedResult: [NSRange]!
        
        beforeEach {
            sut = context().0
            searchString = context().1
            expectedResult = context().2
        }
        
        it("contains the expected ranges") {
            guard let ranges = sut.ranges(of: searchString) else {
                XCTFail()
                return
            }
            
            expect(ranges).to(equal(expectedResult))
        }
    }
}

private class DoesNotContainSearchString: Behavior<(String, String)> {
    override class func spec(_ context: @escaping () -> (String, String)) {
        
        var sut: String!
        var searchString: String!
        
        beforeEach {
            sut = context().0
            searchString = context().1
        }
        
        it("does not contain the search string") {
            let ranges = sut.ranges(of: searchString)
            expect(ranges).to(beNil())
        }
    }
}
