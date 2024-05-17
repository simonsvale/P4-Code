import matlab.mock.TestCase
import matlab.unittest.constraints.IsLessThan

testCase = TestCase.forInteractiveUse;

% [mock,behavior] = testCase.createMock("AddedMethods",["deposit" "isOpen"]);
[mock,behavior] = testCase.createMock('AddedProperties',{'Prop1','Prop2'});

testCase.assertEqual('Prop1', mock.Prop1)

%testCase.throwExceptionWhen(behavior.deposit(IsLessThan(0)), ...
%    MException("Account:deposit:Negative", ...
%   "Deposit amount must be positive."))

%mock.deposit(100)

%testCase.verifyCalled(behavior.deposit(100))