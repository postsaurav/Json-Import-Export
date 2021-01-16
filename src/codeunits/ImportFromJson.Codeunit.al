codeunit 50001 "SDH Import From Json"
{

    procedure ImportPurchaseOrderFromJson()
    var
        InputToken: JsonToken;
    begin
        RequestFileFromUser(InputToken);
        ImportPurchaseOrder(InputToken);
    end;

    local procedure RequestFileFromUser(InputToken: JsonToken)
    var
        InputFilename: Text;
        IStream: InStream;
    begin
        If UploadIntoStream('Select File to Import', '', '*.*|*.json', InputFilename, IStream) then
            InputToken.ReadFrom(IStream);
    end;

    local procedure ImportPurchaseOrder(InputToken: JsonToken)
    var
        OrdersObject: JsonObject;
        OrderObject: JsonObject;

        OrderTokenArray: JsonToken;
        OrderToken: JsonToken;

        PurchaseHeader: Record "Purchase Header";
    begin
        If not InputToken.IsObject then
            exit;

        OrdersObject := InputToken.AsObject();

        If OrdersObject.Contains('Orders') then
            If OrdersObject.Get('Orders', OrderTokenArray) then
                foreach OrderToken in OrderTokenArray.AsArray() do begin
                    OrderObject := OrderToken.AsObject();
                    Clear(PurchaseHeader);
                    If GetPurchaseHeaderDetails(OrderObject, PurchaseHeader) then
                        GetPurchaseLineDetails(OrderObject, PurchaseHeader);
                end;
    end;

    local procedure GetPurchaseHeaderDetails(OrderObject: JsonObject; Var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        OrderDate: Date;
        VendorNo: Code[20];
        ValueToken: JsonToken;
    begin
        If OrderObject.Get('Order Date', ValueToken) then
            OrderDate := ValueToken.AsValue().AsDate();

        If OrderObject.Get('Buy-from Vendor No.', ValueToken) then
            VendorNo := ValueToken.AsValue().AsCode();

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.Validate("Order Date", OrderDate);
        PurchaseHeader.Modify(true);
        Exit(true);
    end;

    local procedure GetPurchaseLineDetails(OrderObject: JsonObject; PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        LineObject: JsonObject;
        LineTokenArray: JsonToken;
        LineToken: JsonToken;
        ValueToken: JsonToken;
        ItemNo: Code[20];
        LineQty: Decimal;
    begin
        If OrderObject.Contains('lines') then
            If OrderObject.Get('lines', LineTokenArray) then
                foreach LineToken in LinetokenArray.AsArray() do begin
                    LineObject := LineToken.AsObject();

                    If LineObject.Get('No.', ValueToken) then
                        ItemNo := ValueToken.AsValue().AsCode();

                    If LineObject.Get('Quantity', ValueToken) then
                        LineQty := ValueToken.AsValue().AsDecimal();

                    Purchaseline.Init();
                    Purchaseline."Document Type" := PurchaseHeader."Document Type";
                    Purchaseline."Document No." := PurchaseHeader."No.";
                    Purchaseline."Line No." := GetNextPurchaseLineNo(PurchaseHeader);
                    Purchaseline.Insert(True);
                    Purchaseline.Type := Purchaseline.Type::Item;
                    Purchaseline.Validate("No.", ItemNo);
                    Purchaseline.Validate(Quantity, LineQty);
                    Purchaseline.Modify(true);

                    If LineObject.Contains('comment') then
                        InsertLineComments(LineObject, PurchaseLine);
                end;
    end;

    local procedure GetNextPurchaseLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        IF PurchaseLine.FindLast() then
            Exit(PurchaseLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure InsertLineComments(LineObject: JsonObject; PurchaseLine: Record "Purchase Line")
    var
        PurchaseCommentLine: Record "Purch. Comment Line";
        LineCommentObject: JsonObject;
        LineCommentTokenArray: JsonToken;
        LinecommentToken: JsonToken;
        ValueToken: JsonToken;
        LineComment: Text[80];
        CommentDate: Date;
    begin
        If LineObject.Contains('comment') then
            If LineObject.Get('comment', LineCommentTokenArray) then
                foreach LinecommentToken in LineCommentTokenArray.AsArray() do begin
                    LineCommentObject := LinecommentToken.AsObject();
                    If LineCommentObject.Get('comment', ValueToken) then
                        LineComment := ValueToken.AsValue().AsText();
                    If LineCommentObject.Get('date', ValueToken) then
                        CommentDate := ValueToken.AsValue().AsDate();

                    PurchaseCommentLine.Init();
                    PurchaseCommentLine."Document Type" := PurchaseLine."Document Type";
                    PurchaseCommentLine."No." := PurchaseLine."Document No.";
                    PurchaseCommentLine."Line No." := GetNextPurchaseCommentLineNo(PurchaseLine);
                    PurchaseCommentLine."Document Line No." := PurchaseLine."Line No.";
                    PurchaseCommentLine.Comment := LineComment;
                    PurchaseCommentLine.Date := CommentDate;
                    PurchaseCommentLine.Insert(true);
                end;
    end;

    local procedure GetNextPurchaseCommentLineNo(PurchaseLine: Record "Purchase Line"): Integer
    var
        PurchaseCommentLine: Record "Purch. Comment Line";
    begin
        PurchaseCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchaseCommentLine.SetRange("No.", PurchaseLine."Document No.");
        IF PurchaseCommentLine.FindLast() then
            Exit(PurchaseCommentLine."Line No." + 10000);
        exit(10000);
    end;
}