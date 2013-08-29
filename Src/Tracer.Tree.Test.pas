unit Tracer.Tree.Test;

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

interface

{$I CheckTestFramework.Inc}

uses
  TestFramework,
  TestFramework.BaseTestCase,
  Tracer.Tree;

type
  TTracerTreeTest = class(TBaseTestCase)
  protected
    Tree: TTracerTree;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    function ToString(const Tree: TTracerTree): string;
  published
    procedure TestParseLog1;
    procedure TestParseLog2;
    procedure TestParseBuildTree1;
    procedure TestParseBuildTree2;
  end;

implementation

uses
  Tracer.Tools,
  System.SysUtils;

{ TTracerTreeTest }

procedure TTracerTreeTest.SetUp;
begin
  Tree := TTracerTree.Create;
end;

procedure TTracerTreeTest.TearDown;
begin
  Tree.Free;
  Tree := nil;
end;

procedure TTracerTreeTest.TestParseBuildTree1;
begin
  Tree.ParseLog(LoadStringFromFile(Fixture('logs\log1.txt')));
  Tree.BuildTree;
  Tree.MergeFunctions;
  Tree.MergeDouble;
  CheckEquals(''
  + #13#10'root'
  + #13#10'  ?'
  + #13#10'    initialization'
  + #13#10'      Execute'
  + #13#10'        Execute'
  + #13#10'          @IntfCopy'
  + #13#10'            TTracerInterfacedObject._AddRef'
  + #13#10'        Execute'
  + #13#10'          @IntfClear'
  + #13#10'            TTracerInterfacedObject._Release'
  + #13#10, #13#10 + ToString(Tree));
end;

procedure TTracerTreeTest.TestParseBuildTree2;
begin
  Tree.ParseLog(LoadStringFromFile(Fixture('logs\log2.txt')));
  Tree.BuildTree;
  Tree.MergeFunctions;
  Tree.MergeDouble;
  CheckEquals(''
  + #13#10'root'
  + #13#10'  ?'
  + #13#10'    initialization'
  + #13#10'      Execute'
  + #13#10'        Execute'
  + #13#10'          @IntfCopy'
  + #13#10'            TTracerInterfacedObject._AddRef'
  + #13#10'        Execute'
  + #13#10'          @IntfCopy'
  + #13#10'            TTracerInterfacedObject._AddRef'
  + #13#10'        Execute'
  + #13#10'          @IntfCopy'
  + #13#10'            TTracerInterfacedObject._AddRef'
  + #13#10'        Execute'
  + #13#10'          @IntfCopy'
  + #13#10'            TTracerInterfacedObject._AddRef'
  + #13#10'        Execute'
  + #13#10'          @FinalizeArray'
  + #13#10'            @IntfClear'
  + #13#10'              TTracerInterfacedObject._Release'
  + #13#10, #13#10 + ToString(Tree));
end;

procedure TTracerTreeTest.TestParseLog1;
begin
  Tree.ParseLog(LoadStringFromFile(Fixture('logs\log1.txt')));
  CheckEquals(2, Tree.Root.Count);
end;

procedure TTracerTreeTest.TestParseLog2;
begin
  Tree.ParseLog(LoadStringFromFile(Fixture('logs\log2.txt')));
  CheckEquals(6, Tree.Root.Count);
end;

function TTracerTreeTest.ToString(const Tree: TTracerTree): string;
  function Caption(const Node: TTracerTreeNode; const Level: Integer): string;
  begin
    Result := Node.Content[tcFunction];

    if Result = '' then
      if Level = 0 then
        Result := 'root' else
        Result := '?';
  end;

  procedure Iterate(const Node: TTracerTreeNode; const Level: Integer);
  var
    i: Integer;
  begin
    Result := Result + ''.PadLeft(Level * 2, ' ') + Caption(Node, Level) + #13#10;
    for i := 0 to Node.Count - 1 do
      Iterate(Node[i], Level + 1); // recursion
  end;
begin
  Result := '';
  Iterate(Tree.Root, 0);
end;

initialization
  RegisterTest(TTracerTreeTest.Suite);
end.