pageextension 50000 SDHPurchaseOrderList extends "Purchase Order List"
{
    actions
    {
        addfirst(processing)
        {
            action("Download Json")
            {
                ToolTip = 'This Action Download the Purchase order as JSon';
                ApplicationArea = All;
                Promoted = True;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Export;
                trigger OnAction()
                var
                    ExportToJson: Codeunit "SDH Export To Json";
                begin
                    ExportToJson.ExportPurchaseOrderAsJson(Rec);
                end;
            }
            action("Upload Json")
            {
                ToolTip = 'This Action Upload the Purchase order as JSon';
                ApplicationArea = All;
                Promoted = True;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Import;
                trigger OnAction()
                var
                    ImportFromJson: Codeunit "SDH Import From Json";
                begin
                    ImportFromJson.ImportPurchaseOrderFromJson();
                end;
            }
        }
    }
}