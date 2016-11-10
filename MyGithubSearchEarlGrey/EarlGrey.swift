//
// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

public func EarlGrey() -> EarlGreyImpl {
    return EarlGreyImpl.invoked(fromFile: #file, lineNumber: #line)
}

public func GREYAssert(_ expression: @autoclosure () -> Bool, reason: String) {
    GREYAssert(expression, reason, details: "Expected expression to be true")
}

public func GREYAssertTrue(_ expression: @autoclosure () -> Bool, reason: String) {
    GREYAssert(expression().boolValue,
               reason,
               details: "Expected the boolean expression to be true")
}

public func GREYAssertFalse(_ expression: @autoclosure () -> Bool, reason: String) {
    GREYAssert(!expression().boolValue,
               reason,
               details: "Expected the boolean expression to be true")
}

public func GREYAssertNotNil(_ expression: @autoclosure () -> Any?, reason: String) {
    GREYAssert(expression() != nil, reason, details: "Expected expression to be not nil")
}

public func GREYAssertNil(_ expression: @autoclosure () -> Any?, reason: String) {
    GREYAssert(expression() == nil, reason, details: "Expected expression to be nil")
}

public func GREYAssertEqual<T : Equatable>(_ left: @autoclosure () -> T?,
                            _ right: @autoclosure () -> T?, reason: String) {
    GREYAssert(left() == right(), reason, details: "Expeted left term to be equal to right term")
}

public func GREYFail(_ reason: String) {
    greyFailureHandler.handle(GREYFrameworkException(name: kGREYAssertionFailedException,
        reason: reason),
                                       details: "")
}

public func GREYFail(_ reason: String, details: String) {
    greyFailureHandler.handle(GREYFrameworkException(name: kGREYAssertionFailedException,
        reason: reason),
                                       details: details)
}

private func GREYAssert(_ expression: @autoclosure () -> Bool,
                                     _ reason: String, details: String) {
    GREYSetCurrentAsFailable()
    if !expression().boolValue {
        greyFailureHandler.handle(GREYFrameworkException(name: kGREYAssertionFailedException,
            reason: reason),
                                           details: details)
    }
}

private func GREYSetCurrentAsFailable() {
    let greyFailureHandlerSelector =
        #selector(GREYFailureHandler.setInvocationFile(_:andInvocationLine:))
    if greyFailureHandler.responds(to: greyFailureHandlerSelector) {
        greyFailureHandler.setInvocationFile!(#file, andInvocationLine: #line)
    }
}
