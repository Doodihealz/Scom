using System;

namespace SupComStyleUI;

// Logical canvas geometry. The parent canvas retains responsibility for physical
// UI scaling, so resizing gains usable rows instead of magnifying a fixed dialog.
internal readonly struct UnitManagerLayout
{
    public readonly float Width, Height, Padding, SidebarWidth, CatalogX, CatalogWidth;
    public readonly float RowsY, RowsHeight, RowHeight, SummaryY, EditActionsY, CloseActionsY;
    public readonly float NameX, NameWidth, IdX, IdWidth, FactionX, FactionWidth, TierX, TierWidth, StateX, StateWidth;
    public readonly int RowsPerPage;

    private UnitManagerLayout(float availableWidth, float availableHeight, float fontSize)
    {
        Width = availableWidth * .96f;
        Height = availableHeight * .96f;
        Padding = Math.Max(14f, Math.Min(24f, Width * .0125f));
        SidebarWidth = Math.Max(180f, Math.Min(310f, Width * .20f));
        CatalogX = Padding + SidebarWidth + 16f;
        CatalogWidth = Width - CatalogX - Padding;
        RowHeight = Math.Max(30f, (float)Math.Ceiling(Math.Max(14f, Math.Min(20f, fontSize)) * 1.55f + 5f));
        RowsY = 178f;
        bool narrow = Width < 1100f;
        SummaryY = Height - (narrow ? 116f : 80f);
        EditActionsY = Height - (narrow ? 78f : 44f);
        CloseActionsY = Height - 44f;
        RowsHeight = Math.Max(RowHeight, SummaryY - RowsY - 10f);
        RowsPerPage = Math.Max(1, (int)Math.Floor(RowsHeight / RowHeight));

        const float gap = 10f;
        NameX = 10f;
        StateWidth = Math.Max(90f, Math.Min(120f, CatalogWidth * .14f));
        TierWidth = Math.Max(60f, Math.Min(110f, CatalogWidth * .11f));
        FactionWidth = Math.Max(70f, Math.Min(140f, CatalogWidth * .13f));
        IdWidth = Math.Max(80f, Math.Min(160f, CatalogWidth * .15f));
        StateX = CatalogWidth - StateWidth - 8f;
        TierX = StateX - gap - TierWidth;
        FactionX = TierX - gap - FactionWidth;
        IdX = FactionX - gap - IdWidth;
        NameWidth = Math.Max(60f, IdX - gap - NameX);
    }

    public static UnitManagerLayout Calculate(float availableWidth, float availableHeight, float fontSize)
    {
        if (float.IsNaN(availableWidth) || float.IsInfinity(availableWidth) || availableWidth < 700f ||
            float.IsNaN(availableHeight) || float.IsInfinity(availableHeight) || availableHeight < 400f)
            throw new ArgumentOutOfRangeException("availableWidth", "The Unit Manager requires at least a 700 by 400 logical canvas.");
        return new UnitManagerLayout(availableWidth, availableHeight, fontSize);
    }

    public static int PageCount(int itemCount, int pageSize)
    {
        if (itemCount < 0 || pageSize < 1) throw new ArgumentOutOfRangeException("pageSize");
        return Math.Max(1, itemCount / pageSize + (itemCount % pageSize == 0 ? 0 : 1));
    }

    public static int ClampPage(int page, int itemCount, int pageSize)
        => Math.Max(0, Math.Min(page, PageCount(itemCount, pageSize) - 1));

    public static int PreserveFirstItemPage(int oldPage, int oldSize, int newSize)
    {
        if (oldPage < 0 || oldSize < 1 || newSize < 1) throw new ArgumentOutOfRangeException("newSize");
        return (int)Math.Min(int.MaxValue, (long)oldPage * oldSize / newSize);
    }
}
