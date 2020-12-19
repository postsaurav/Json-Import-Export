codeunit 50000 "SDH Export To Json"
{
    procedure ExportPurchaseOrderAsJson(PurchaseHeader: Record "Purchase Header")
    var
        Tempblob: Codeunit "Temp Blob";
        PurchaseOrerJson: JsonObject;
        IStream: InStream;
        OStream: OutStream;
        ExportFileName: Text;
    begin
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("No."), PurchaseHeader."No.");
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("Order Date"), PurchaseHeader."Order Date");
        PurchaseOrerJson.Add(PurchaseHeader.FieldCaption("Buy-from Vendor No."), PurchaseHeader."Buy-from Vendor No.");
        PurchaseOrerJson.Add('lines', GetPurchaseLineArray(PurchaseHeader));
        Tempblob.CreateOutStream(OStream);
        IF PurchaseOrerJson.WriteTo(OStream) THEN begin
            ExportFileName := 'Purchase order' + PurchaseHeader."No." + '.json';
            Tempblob.CreateInStream(IStream);
            DownloadFromStream(IStream, '', '', '', ExportFileName);
        end;
    end;

    local procedure GetPurchaseLineArray(PurchaseHeader: Record "Purchase Header") PurchaseLineArray: JsonArray
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                ExportPurchaseLines(PurchaseLine, PurchaseLineArray);
            until (PurchaseLine.Next() = 0);
    end;

    local procedure ExportPurchaseLines(PurchaseLine: Record "Purchase Line"; PurchaseLineArray: JsonArray)
    var
        PurchaseLineJson: JsonObject;
    begin
        PurchaseLineJson.Add(PurchaseLine.FieldCaption(Type), FORMAT(PurchaseLine.Type));
        PurchaseLineJson.Add(PurchaseLine.FieldCaption("No."), PurchaseLine."No.");
        PurchaseLineJson.Add(PurchaseLine.FieldCaption(Quantity), PurchaseLine.Quantity);
        If PurchaseCommentExist(PurchaseLine) then
            PurchaseLineJson.Add('comment', GetPurchaseLineCommentArray(PurchaseLine));
        PurchaseLineArray.Add(PurchaseLineJson);
    end;

    local procedure GetPurchaseLineCommentArray(PurchaseLine: Record "Purchase Line") CommentLineArray: JsonArray
    var
        PurchaseCommentLine: Record "Purch. Comment Line";
    begin
        PurchaseCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchaseCommentLine.SetRange("No.", PurchaseLine."Document No.");
        IF PurchaseCommentLine.FindSet() then
            repeat
                ExportPurchaseLineComments(PurchaseCommentLine, CommentLineArray);
            until (PurchaseCommentLine.Next() = 0);
    end;

    local procedure ExportPurchaseLineComments(PurchaseLineComments: Record "Purch. Comment Line"; CommentLineArray: JsonArray)
    var
        PurchaseLineCommentJson: JsonObject;
    begin
        PurchaseLineCommentJson.Add('comment', PurchaseLineComments.Comment);
        PurchaseLineCommentJson.Add('date', PurchaseLineComments.Date);
        CommentLineArray.Add(PurchaseLineCommentJson);
    end;

    local procedure PurchaseCommentExist(PurchaseLine: Record "Purchase Line"): Boolean
    var
        PurchaseCommentLine: Record "Purch. Comment Line";

    begin
        PurchaseCommentLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseCommentLine.SetRange("Document Line No.", PurchaseLine."Line No.");
        PurchaseCommentLine.SetRange("No.", PurchaseLine."Document No.");
        Exit(NOT PurchaseCommentLine.IsEmpty);
    end;
}