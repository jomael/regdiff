{                                                                             }
{  Copyright (C) 2007 Miguel E. Hernández Cuervo                              }
{                                                                             }
{ Licensed under the Apache License, Version 2.0 (the "License");             }
{ you may not use this file except in compliance with the License.            }
{ You may obtain a copy of the License at                                     }
{                                                                             }
{      http://www.apache.org/licenses/LICENSE-2.0                             }
{                                                                             }
{ Unless required by applicable law or agreed to in writing, software         }
{ distributed under the License is distributed on an "AS IS" BASIS,           }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{ See the License for the specific language governing permissions and         }
{ limitations under the License.                                              }
{                                                                             }


unit RegistryTree;

interface

uses
  Classes, Windows, SysUtils;

type
  PRegistryEntry    = ^RegistryEntry;
  PRegistryKey      = ^RegistryKey;
  PRegistryValue    = ^RegistryValue;
  EntrySearchResult = (NotFound, FullMatch, PartialMatch);
  
  {                                                                           }
  {  RegistryEntry                                                            }
  {                                                                           }
  RegistryEntry = class
  public
    Name        : PAnsiChar;
    NameLength  : Cardinal;
    Parent      : PRegistryKey;

    constructor Create(NameSize : Cardinal);                       virtual;
    destructor  Delete;                                            virtual;
    function    isValue : ByteBool;                                virtual;
    function    isKey   : ByteBool;                                virtual;
    procedure   SetName(const NewName : PAnsiChar; NameSize : Cardinal);
    procedure   Clear;                                             virtual;
    function    GetName : AnsiString;
    function    GetFullPath : AnsiString;

    procedure   WriteToFile(var OutFile : TextFile);               virtual;
    procedure   WriteKeysToFile(var OutFile : TextFile);           virtual;
    procedure   WriteValuesToFile(var OutFile : TextFile);         virtual;
  end;

  {                                                                           }
  {  RegistryKey                                                              }
  {                                                                           }
  RegistryKey = class(RegistryEntry)
  public
    SubEntries : TList;

    constructor Create(NameSize : Cardinal); override;
    destructor  Delete; override;
    procedure   Clear; override;
    function    isKey : ByteBool; override;

    procedure   WriteToFile(var OutFile : TextFile); override;
    procedure   WriteKeysToFile(var OutFile : TextFile); override;
    procedure   WriteValuesToFile(var OutFile : TextFile); override;
  end;

  {                                                                           }
  {  RegistryValue                                                            }
  {                                                                           }
  RegistryValue = class(RegistryEntry)
  public
    TypeCode    : Cardinal;
    Value       : PByte;
    ValueLength : Cardinal;

    constructor Create(NameSize : Cardinal; ValueSize : Cardinal); reintroduce;
    destructor  Delete; override;
    procedure   Clear; override;
    procedure   SetValue(const NewValue : PByte; ValueSize : Cardinal);
    function    isValue : ByteBool; override;

    procedure   WriteToFile(var OutFile : TextFile); override;
  end;
  
  {                                                                           }
  {  RegistryRoot                                                             }
  {                                                                           }
  RegistryRoot = class
  private
    procedure ShotR(KeyRoot : HKEY; Parent : PRegistryKey);
    procedure CompareR(Key1 : PRegistryKey; Key2 : PRegistryKey);
    function  CompareName(Name1 : PAnsiChar; Size1 : Cardinal;
                          Name2 : PAnsiChar; Size2 : Cardinal)
                          : ByteBool;
    function  CompareValue(Value1 : PByte; Size1 : Cardinal; Value2 : PByte;
                           Size2 : Cardinal)
                           : ByteBool;
    function  SearchAndDeleteEntry(var List : TList; Entry : PRegistryEntry;
                                   var OldEntry : PRegistryEntry)
                                   : EntrySearchResult;
    procedure WriteListKeysToFile(var OutFile : TextFile; var List : TList);
    procedure WriteListValuesToFile(var OutFile : TextFile; var List : TList);
  public
    RootKeyID        : HKEY;
    RootKey          : RegistryKey;
    RootKey2         : RegistryKey;
    HasAValidRootKey : ByteBool;
    Shot1Ready       : ByteBool;
    Shot2Ready       : ByteBool;
    CompareReady     : ByteBool;
    ValueCount       : Cardinal;
    KeyCount         : Cardinal;
    {Compare result}
    Added            : TList;
    Modified         : TList;
    Old              : TList;
    Deleted          : TList;
    KeysAdded        : Cardinal;
    ValuesAdded      : Cardinal;
    ValuesModified   : Cardinal;
    KeysDeleted      : Cardinal;
    ValuesDeleted    : Cardinal;

    constructor Create(Root : HKEY);
    destructor  Delete;
    procedure   Clear;
    procedure   Shot1;
    procedure   Shot2;
    procedure   Compare;
    procedure   WriteToFile(var OutFile : TextFile);
    procedure   WriteKeysToFile(var OutFile : TextFile);
    procedure   WriteValuesToFile(var OutFile : TextFile);
    procedure   WriteCreatedValuesToFile(var OutFile : TextFile);
    procedure   WriteDeletedValuesToFile(var OutFile : TextFile);
    procedure   WriteModifiedValuesToFile(var OutFile : TextFile);
    procedure   WriteCreatedKeysToFile(var OutFile : TextFile);
    procedure   WriteDeletedKeysToFile(var OutFile : TextFile);
  end;

implementation

  {                                                                           }
  {  RegistryEntry                                                            }
  {                                                                           }
  constructor RegistryEntry.Create(NameSize : Cardinal);
  begin
    if NameSize = 0 then
      Name := nil
    else
      GetMem(Name, NameSize);
    NameLength := NameSize;
    Parent := nil;
  end;
  
  destructor RegistryEntry.Delete;
  begin
    if Name <> nil then
      FreeMem(Name);
  end;
  
  function RegistryEntry.isValue : ByteBool;
  begin
    Result := False;
  end;

  function RegistryEntry.isKey : ByteBool;
  begin
    Result := False;
  end;

  procedure RegistryEntry.SetName(const NewName : PAnsiChar;
                                  NameSize : Cardinal);
  begin
    if NameSize <> NameLength then
    begin
      FreeMem(Name);
      if NameSize <> 0 then
        GetMem(Name, NameSize)
      else
        Name := nil;
      NameLength := NameSize;
    end;
    CopyMemory(Name, NewName, NameSize);
  end;

  procedure RegistryEntry.Clear;
  begin
    if Name <> nil then
    begin
      FreeMem(Name);
      Name       := nil;
    end;
    NameLength := 0;
  end;

  procedure RegistryEntry.WriteToFile(var OutFile : TextFile);
  begin
    Writeln(OutFile, GetFullPath);
  end;

  procedure RegistryEntry.WriteKeysToFile(var OutFile : TextFile);
  begin
    if isKey then
      WriteToFile(OutFile);
  end;

  procedure RegistryEntry.WriteValuesToFile(var OutFile : TextFile);
  begin
    if isValue then
      WriteToFile(OutFile);
  end;

  function RegistryEntry.GetName : AnsiString;
  begin
    Result := AnsiString(Name);
    SetLength(Result, NameLength);
  end;

  function RegistryEntry.GetFullPath : AnsiString;
  var
    StringList : TStringList;
    Temp       : PRegistryKey;
    i          : Integer;
  begin
    StringList := TStringList.Create;
    Temp := Parent;
    while Temp <> nil do
    begin
      StringList.Add(Temp^.GetName);
      Temp := Temp.Parent;
    end;
    Result := '';
    for i := (StringList.Count - 1) downto 0 do
    begin
      Result := Result + StringList.Strings[i] + '\';
    end;
    Result := Result + GetName;
    if (isKey) then
      Result := Result + '\';
    StringList.Free;
  end;

  {                                                                           }
  {  RegistryKey                                                              }
  {                                                                           }
  constructor RegistryKey.Create(NameSize : Cardinal);
  begin
    inherited Create(NameSize);
    SubEntries := TList.Create;
  end;

  destructor RegistryKey.Delete;
  var
    i    : Integer;
    Temp : PRegistryEntry;
  begin
    for i := 0 to SubEntries.Count - 1 do
    begin
      Temp := SubEntries.Items[i];
      Temp^.Delete;
      Dispose(Temp);
    end;
    inherited Delete;
    SubEntries.Free;
  end;

  function RegistryKey.isKey : ByteBool;
  begin
    Result := True;
  end;

  procedure RegistryKey.Clear;
  var
    Temp : PRegistryEntry;
    i    : Cardinal;
  begin
    if SubEntries.Count = 0 then
      Exit;
    for i := 0 to SubEntries.Count - 1 do
    begin
      Temp := SubEntries.Items[i];
      Temp^.Delete;
      Dispose(Temp);
    end;
    SubEntries.Clear;
  end;

  procedure RegistryKey.WriteToFile(var OutFile : TextFile);
  var
    Temp : PRegistryEntry;
    i    : Cardinal;
  begin
    inherited WriteToFile(OutFile);
    if SubEntries.Count = 0 then
      Exit;
    for i := 0 to SubEntries.Count - 1 do
    begin
      Temp := SubEntries.Items[i];
      Temp^.WriteToFile(OutFile);
    end;
  end;

  procedure RegistryKey.WriteKeysToFile(var OutFile : TextFile);
  var
    Temp : PRegistryEntry;
    i    : Cardinal;
  begin
    inherited WriteToFile(OutFile);
    if SubEntries.Count = 0 then
      Exit;
    for i := 0 to SubEntries.Count - 1 do
    begin
      Temp := SubEntries.Items[i];
      Temp^.WriteKeysToFile(OutFile);
    end;
  end;

  procedure RegistryKey.WriteValuesToFile(var OutFile : TextFile);
  var
    Temp : PRegistryEntry;
    i    : Cardinal;
  begin
    if SubEntries.Count = 0 then
      Exit;
    for i := 0 to SubEntries.Count - 1 do
    begin
      Temp := SubEntries.Items[i];
      if Temp^.isValue then
        Temp^.WriteToFile(OutFile)
      else
        Temp^.WriteValuesToFile(OutFile);
    end;
  end;

  {                                                                           }
  {  RegistryValue                                                            }
  {                                                                           }
  constructor RegistryValue.Create(NameSize : Cardinal; ValueSize : Cardinal);
  begin
    inherited Create(NameSize);
    if ValueSize = 0 then
      Value := nil
    else
      GetMem(Value, ValueSize);
    ValueLength := ValueSize;
  end;

  destructor RegistryValue.Delete;
  begin
    inherited Delete;
    if Value <> nil then
      FreeMem(Value);
  end;

  procedure RegistryValue.Clear;
  begin
    inherited Clear;
    if Value <> nil then
    begin
      FreeMem(Value);
      Value := nil;
    end;
    ValueLength := 0;
  end;

  procedure RegistryValue.SetValue(const NewValue : PByte;
                                   ValueSize : Cardinal);
  begin
    if ValueSize <> ValueLength then
    begin
      FreeMem(Value);
      if ValueSize <> 0 then
        GetMem(Value, ValueSize)
      else
        Value := nil;
      ValueLength := ValueSize;
    end;
    CopyMemory(Value, NewValue, ValueSize);
  end;

  function RegistryValue.isValue : ByteBool;
  begin
    Result := True;
  end;

  procedure RegistryValue.WriteToFile(var OutFile : TextFile);
  var
    s : AnsiString;
  begin
    Write(OutFile, GetFullPath + ': ');
    if ValueLength >= 2 then
    begin
      case TypeCode of
        REG_DWORD:
        begin
          Writeln(OutFile, PCardinal(Value)^);
        end;
        REG_SZ, REG_EXPAND_SZ:
        begin
          Write(OutFile, '"');
          SetLength(s, ValueLength - 1);
          CopyMemory(PByte(s), Value, ValueLength);
          Write(OutFile, s);
          Writeln(OutFile, '"');
        end
        else
        begin
          Writeln(OutFile, '(NOT PRINTED)');
        end;
      end;
    end
    else
      Writeln(OutFile, '(EMPTY)');
  end;

  {                                                                           }
  {  RegistryRoot                                                             }
  {                                                                           }
  constructor RegistryRoot.Create(Root : HKEY);
  var
    KeyName    : PAnsiChar;
    NameLength : Cardinal;
  begin
    RootKeyID      := 0;
    Shot1Ready     := False;
    Shot2Ready     := False;
    Added          := TList.Create;
    Modified       := TList.Create;
    Old            := TList.Create;
    Deleted        := TList.Create;
    KeyCount       := 0;
    ValueCount     := 0;
    KeyName        := '';

    case Root of
      HKEY_LOCAL_MACHINE:
      begin
        KeyName   := 'HKEY_LOCAL_MACHINE';
        RootKeyID := HKEY_LOCAL_MACHINE;
      end;
      HKEY_USERS:
      begin
        KeyName   := 'HKEY_USERS';
        RootKeyID := HKEY_USERS;
      end;
      HKEY_CLASSES_ROOT:
      begin
        KeyName   := 'HKEY_CLASSES_ROOT';
        RootKeyID := HKEY_CLASSES_ROOT;
      end;
      HKEY_CURRENT_USER:
      begin
        KeyName   := 'HKEY_CURRENT_USER';
        RootKeyID := HKEY_CURRENT_USER;
      end;
      HKEY_CURRENT_CONFIG:
      begin
        KeyName   := 'HKEY_CURRENT_CONFIG';
        RootKeyID := HKEY_CURRENT_CONFIG;
      end;
      HKEY_PERFORMANCE_DATA:
      begin
        KeyName   := 'HKEY_PERFORMANCE_DATA';
        RootKeyID := HKEY_PERFORMANCE_DATA;
      end;
    end;
    if RootKeyID <> 0 then
    begin
      NameLength := Length(AnsiString(KeyName));
      RootKey    := RegistryKey.Create(NameLength);
      RootKey2   := RegistryKey.Create(NameLength);
      RootKey.SetName(KeyName, NameLength);
      RootKey2.SetName(KeyName, NameLength);
      HasAValidRootKey := True;
      KeyCount := 1;
    end
    else
      HasAValidRootKey  := False;
  end;

  destructor RegistryRoot.Delete;
  begin
    if HasAValidRootKey then
    begin
      RootKey.Delete;
      RootKey2.Delete;
    end;
    Added.Free;
    Modified.Free;
    Old.Free;
    Deleted.Free;
  end;

  procedure RegistryRoot.Clear;
  begin
    Shot1Ready   := False;
    Shot2Ready   := False;
    KeyCount     := 0;
    ValueCount   := 0;
    Added.Clear;
    Modified.Clear;
    Old.Clear;
    Deleted.Clear;
    if HasAValidRootKey then
    begin
      RootKey.Clear;
      RootKey2.Clear;
      KeyCount := 1;
    end;
  end;

  procedure RegistryRoot.ShotR(KeyRoot : HKEY; Parent : PRegistryKey);
  var
    Key                       : HKEY;
    Error                     : Longint;
    i                         : Cardinal;
    ValueName                 : PChar;
    KeyName                   : PChar;
    ValueData                 : PByte;
    TypeCode                  : Cardinal;
    LengthOfKeyName           : Cardinal;
    LengthOfValueName         : Cardinal;
    LengthOfValueData         : Cardinal;
    LengthOfLongestSubkeyName : Cardinal;
    LengthOfLongestValueName  : Cardinal;
    LengthOfLongestValueData  : Cardinal;
    KeyEntry                  : PRegistryKey;
    ValueEntry                : PRegistryValue;
  begin
    Error := RegQueryInfoKey(KeyRoot, nil, nil, nil, nil,
                             @LengthOfLongestSubkeyName, nil, nil,
                             @LengthOfLongestValueName,
                             @LengthOfLongestValueData, nil, nil);
    if Error = ERROR_SUCCESS then
    begin
      Inc(LengthOfLongestSubkeyName);
      Inc(LengthOfLongestValueName);
      GetMem(ValueName, LengthOfLongestValueName);
      GetMem(ValueData, LengthOfLongestValueData);
      i := 0;
      while Error <> ERROR_NO_MORE_ITEMS do
      begin
        LengthOfValueName := LengthOfLongestValueName;
        LengthOfValueData := LengthOfLongestValueData;
        Error := RegEnumValue(KeyRoot, i, PAnsiChar(ValueName),
                              LengthOfValueName, nil, @TypeCode, ValueData,
                              @LengthOfValueData);
        if Error = ERROR_SUCCESS then
        begin
          New(ValueEntry);
          ValueEntry^ := RegistryValue.Create(LengthOfValueName,
                                              LengthOfValueData);
          ValueEntry^.TypeCode := TypeCode;
          ValueEntry^.SetName(ValueName, LengthOfValueName);
          ValueEntry^.SetValue(ValueData, LengthOfValueData);
          ValueEntry^.Parent := Parent;
          if Parent <> nil then
            Parent^.SubEntries.Add(ValueEntry);
          Inc(ValueCount);
        end;
        Inc(i);
      end;
      FreeMem(ValueName);
      FreeMem(ValueData);
      GetMem(KeyName, LengthOfLongestSubkeyName);
      i := 0;
      Error := ERROR_SUCCESS;
      while Error <> ERROR_NO_MORE_ITEMS do
      begin
        LengthOfKeyName := LengthOfLongestSubkeyName;
        Error := RegEnumKeyEx(KeyRoot, i, PChar(KeyName), LengthOfKeyName,
                              nil, nil, nil, nil);
        if Error = ERROR_SUCCESS then
        begin
          New(KeyEntry);
          KeyEntry^ := RegistryKey.Create(LengthOfKeyName);
          KeyEntry^.SetName(KeyName, LengthOfKeyName);
          KeyEntry^.Parent := Parent;
          if Parent <> nil then
            Parent^.SubEntries.Add(KeyEntry);
          Inc(KeyCount);
          if RegOpenKeyEx(KeyRoot, KeyName, 0,
                          KEY_READ, Key) = ERROR_SUCCESS then
          begin
            ShotR(Key, KeyEntry);
          end;
          RegCloseKey(Key);
        end;
        Inc(i);
      end;
      FreeMem(KeyName);
    end;
  end;

  procedure RegistryRoot.Shot1;
  begin
    Clear;
    if HasAValidRootKey then
    begin
      ShotR(RootKeyID, @RootKey);
      Shot1Ready := True;
    end;
  end;

  procedure RegistryRoot.Shot2;
  begin
    if HasAValidRootKey and Shot1Ready then
    begin
      RootKey2.Clear;
      ShotR(RootKeyID, @RootKey2);
      Shot2Ready := True;
    end;
  end;

  function RegistryRoot.CompareName(Name1 : PAnsiChar; Size1 : Cardinal;
                                    Name2 : PAnsiChar; Size2 : Cardinal)
                                    : ByteBool;
  var
    i : Cardinal;
    P : PAnsiChar;
    Q : PAnsiChar;
  begin
    P := Name1;
    Q := Name2;
    if Size1 = Size2 then
    begin
      for i := 1 to Size1 do
      begin
        if P^ <> Q^ then
        begin
          Result := False;
          Exit;
        end;
        Inc(P);
        Inc(Q);
      end;
      Result := True;
    end
    else
      Result := False;
  end;

  function RegistryRoot.CompareValue(Value1 : PByte; Size1 : Cardinal;
                                     Value2 : PByte; Size2 : Cardinal)
                                     : ByteBool;
  var
    i : Cardinal;
    P : PByte;
    Q : PByte;
  begin
    P := Value1;
    Q := Value2;
    if Size1 = Size2 then
    begin
      for i := 1 to Size1 do
      begin
        if P^ <> Q^ then
        begin
          Result := False;
          Exit;
        end;
        Inc(P);
        Inc(Q);
      end;
      Result := True;
    end
    else
      Result := False;
  end;

  function RegistryRoot.SearchAndDeleteEntry(var List : TList;
                                             Entry : PRegistryEntry;
                                             var OldEntry : PRegistryEntry)
                                             : EntrySearchResult;
  var
    i    : Cardinal;
    Temp : PRegistryEntry;
  begin
    if List.Count = 0 then
    begin
      Result := NotFound;
      Exit;
    end;
    for i := 0 to List.Count - 1 do
    begin
      Temp := List.Items[i];
      if CompareName(Entry^.Name, Entry^.NameLength,
                     Temp^.Name , Temp^.NameLength) then
      begin
        if Entry^.isValue then
        begin
          if Temp^.isValue then
          begin
            if CompareValue(PRegistryValue(Entry)^.Value,
                            PRegistryValue(Entry)^.ValueLength,
                            PRegistryValue(Temp)^.Value,
                            PRegistryValue(Temp)^.ValueLength) then
            begin
              Result := FullMatch;
              OldEntry := Temp;
              List.Delete(i);
              Exit;
            end
            else
            begin
              Result := PartialMatch;
              OldEntry := Temp;
              List.Delete(i);
              Exit;
            end;
          end
        end
        else
          if Temp^.isKey then
          begin
            Result := FullMatch;
            OldEntry := Temp;
            List.Delete(i);
            Exit;
          end;
      end;
    end;
    OldEntry := nil;
    Result := NotFound;
  end;

  procedure RegistryRoot.CompareR(Key1 : PRegistryKey; Key2 : PRegistryKey);
  var
    i            : Cardinal;
    Temp         : PRegistryEntry;
    OldEntry     : PRegistryEntry;
    SearchResult : EntrySearchResult;
    TempList     : TList;
  begin
    if Key2^.SubEntries.Count = 0 then
      Exit;
    TempList := TList.Create;
    TempList := Key1^.SubEntries;
    for i := 0 to Key2^.SubEntries.Count - 1 do
    begin
      Temp := Key2^.SubEntries.Items[i];
      SearchResult := SearchAndDeleteEntry(TempList, Temp, OldEntry);
      if SearchResult <> FullMatch then
      begin
        if SearchResult = PartialMatch then
        begin
          Old.Add(OldEntry);
          Modified.Add(Temp);
        end
        else
        begin
          Added.Add(Temp);
        end;
      end
      else
        if Temp^.isKey then
          CompareR(PRegistryKey(OldEntry), PRegistryKey(Temp));
    end;
    if TempList.Count = 0 then
    begin
      TempList.Clear;
      Exit;
    end;
    for i := 0 to TempList.Count - 1 do
    begin
      Temp := TempList.Items[i];
      Deleted.Add(Temp);
    end;
    TempList.Clear;
  end;

  procedure RegistryRoot.Compare;
  begin
    if Shot1Ready and Shot2Ready then
    begin
      CompareR(@RootKey, @RootKey2);
      Shot1Ready := False;
      Shot2Ready := False;
      CompareReady := True;
    end;
  end;

  procedure RegistryRoot.WriteToFile(var OutFile : TextFile);
  begin
    if HasAValidRootKey then
      RootKey.WriteToFile(OutFile);
  end;

  procedure RegistryRoot.WriteKeysToFile(var OutFile : TextFile);
  begin
    if HasAValidRootKey then
      RootKey.WriteKeysToFile(OutFile);
  end;

  procedure RegistryRoot.WriteValuesToFile(var OutFile : TextFile);
  begin
    if HasAValidRootKey then
      RootKey.WriteValuesToFile(OutFile);
  end;

  procedure RegistryRoot.WriteListKeysToFile(var OutFile : TextFile;
                                             var List : TList);
  var
    Temp : PRegistryEntry;
    i    : Integer;
  begin
    if List.Count = 0 then
      Exit;
    for i := 0 to List.Count - 1 do
    begin
      Temp := List.Items[i];
      Temp^.WriteKeysToFile(OutFile);
    end;
  end;

  procedure RegistryRoot.WriteListValuesToFile(var OutFile : TextFile;
                                               var List : TList);
  var
    Temp : PRegistryEntry;
    i    : Cardinal;
  begin
    if List.Count = 0 then
      Exit;
    for i := 0 to List.Count - 1 do
    begin
      Temp := List.Items[i];
      if Temp^.isValue then
        Temp^.WriteToFile(OutFile)
      else
        Temp^.WriteValuesToFile(OutFile);
    end;
  end;

  procedure RegistryRoot.WriteCreatedValuesToFile(var OutFile : TextFile);
  begin
    WriteListValuesToFile(OutFile, Added);
  end;

  procedure RegistryRoot.WriteDeletedValuesToFile(var OutFile : TextFile);
  begin
    WriteListValuesToFile(OutFile, Deleted);
  end;

  procedure RegistryRoot.WriteModifiedValuesToFile(var OutFile : TextFile);
  var
    Temp : PRegistryValue;
    i    : Cardinal;
  begin
    if (Modified.Count = 0) or (Old.Count <> Modified.Count) then
      Exit;
    for i := 0 to Modified.Count - 1 do
    begin
      Temp := Old.Items[i];
      Write(OutFile, 'OLD: ');
      Temp^.WriteToFile(OutFile);
      Temp := Modified.Items[i];
      Write(OutFile, 'NEW: ');
      Temp^.WriteToFile(OutFile);
    end;
  end;

  procedure RegistryRoot.WriteCreatedKeysToFile(var OutFile : TextFile);
  begin
    WriteListKeysToFile(OutFile, Added);
  end;

  procedure RegistryRoot.WriteDeletedKeysToFile(var OutFile : TextFile);
  begin
    WriteListKeysToFile(OutFile, Deleted);
  end;

end.