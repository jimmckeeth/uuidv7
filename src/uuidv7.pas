// Use as a regular unit from Delphi, or run as a console app from FreePascal
unit uuidv7;

interface

uses
  SysUtils, DateUtils;

function GenerateUUIDv7: TGUID;
function GenerateUUIDv7ex(const Timestamp:Int64; const Bytes:TBytes=[]):TGUID;

implementation


function GenerateUUIDv7ex(const Timestamp:Int64; const Bytes:TBytes): TGUID;
var
  randomBytes: array[0..9] of Byte;
  uuid: TGUID;
  i: Integer;
begin
  FillChar(uuid, SizeOf(uuid), 0);

  if Length(Bytes) <> 10 then
  begin
    // Generate 10 random bytes
    for i := 0 to 9 do
      randomBytes[i] := Random($100);
  end
  else
    move(Bytes[0], RandomBytes[0],10);

  // Populate the TGUID fields
  uuid.D1 := (timestamp shr 16) and $FFFFFFFF;       // Top 32 bits of the 48-bit timestamp
  uuid.D2 := ((timestamp shr 4) and $0FFF) or $7000; // Next 12 bits of the timestamp and version 7
  uuid.D3 := ((timestamp and $0000000F) shl 12) or   // the last 4 bits of timestamp
              (randomBytes[0] and $F0);              // the top 4 bits of randomBytes[0]
  uuid.D4[0] := (randomBytes[0] and $0F) or $80;     // Set the variant to 10xx
  Move(randomBytes[1], uuid.D4[1], 7);               // Remaining 7 bytes

  Result := uuid;
end;

function GenerateUUIDv7:TGUID;
var
  timestamp: Int64;
begin
  {$IFDEF FPC}
  timestamp := DateTimeToUnix(Now) * 1000; // seconds accuracy
  {$ELSE}
  timestamp := DateTimeToMilliseconds(Now) - Int64(UnixDateDelta + DateDelta) * MSecsPerDay; // millisecond accuracy
  {$ENDIF}
  Result := GenerateUUIDv7ex(Timestamp,[]);
end;

// Optionally remove this to make a regular unit for FPC too
{$IFDEF FPC}
var i: Integer;
begin
  Randomize;
  for i := 0 to 30 do
    writeln(GUIDToString(GenerateUUIDv7).ToLower);
  readln;
{$ELSE}
initialization
  Randomize;
{$ENDIF}
end.
