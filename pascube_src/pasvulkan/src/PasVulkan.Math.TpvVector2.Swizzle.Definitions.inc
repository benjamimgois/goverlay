private
function GetGG:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetGR:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetRG:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetRR:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetSS:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetST:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetTS:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetTT:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetXX:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetXY:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetYX:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
function GetYY:TpvVector2; {$ifdef CAN_INLINE}inline;{$endif}
procedure SetGR(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
procedure SetRG(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
procedure SetST(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
procedure SetTS(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
procedure SetXY(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
procedure SetYX(const pValue:TpvVector2); {$ifdef CAN_INLINE}inline;{$endif}
public
property gg:TpvVector2 read GetGG;
property gr:TpvVector2 read GetGR write SetGR;
property rg:TpvVector2 read GetRG write SetRG;
property rr:TpvVector2 read GetRR;
property ss:TpvVector2 read GetSS;
property st:TpvVector2 read GetST write SetST;
property ts:TpvVector2 read GetTS write SetTS;
property tt:TpvVector2 read GetTT;
property xx:TpvVector2 read GetXX;
property xy:TpvVector2 read GetXY write SetXY;
property yx:TpvVector2 read GetYX write SetYX;
property yy:TpvVector2 read GetYY;
