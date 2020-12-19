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
                begin

                end;
            }
        }
    }
}