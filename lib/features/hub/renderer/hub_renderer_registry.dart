import '../models/hub_models.dart';

enum HubRendererKind {
  heroCarousel,
  horizontalCards,
  shortcutGrid,
  editorial,
  videoRow,
  liveCard,
  quoteCard,
  shortVideoCarousel,
  unavailable,
}

abstract final class HubRendererRegistry {
  static HubRendererKind resolve(HubSection section) {
    final layout = section.layoutType.trim().toLowerCase();
    if (section.engineType == HubEngineType.unknown && layout.isEmpty) {
      return HubRendererKind.unavailable;
    }
    if (section.engineType == HubEngineType.heroCarousel ||
        const <String>{'hero', 'hero_carousel'}.contains(layout)) {
      return HubRendererKind.heroCarousel;
    }
    if (section.engineType == HubEngineType.shortcutGrid ||
        const <String>{'shortcut_grid', 'icon_grid'}.contains(layout)) {
      return HubRendererKind.shortcutGrid;
    }
    if (section.engineType == HubEngineType.liveChannel ||
        layout == 'live_card') {
      return HubRendererKind.liveCard;
    }
    if (section.engineType == HubEngineType.videoChannel ||
        section.engineType == HubEngineType.externalTvChannel ||
        const <String>{'video_row', 'channel_row', 'playlist_row'}
            .contains(layout)) {
      return HubRendererKind.videoRow;
    }
    if (section.engineType == HubEngineType.quoteChannel ||
        layout == 'quote_card') {
      return HubRendererKind.quoteCard;
    }
    if (section.engineType == HubEngineType.shortVideoChannel ||
        layout == 'short_video_carousel') {
      return HubRendererKind.shortVideoCarousel;
    }
    if (section.engineType == HubEngineType.articleChannel ||
        const <String>{'editorial_list', 'editorial_grid'}.contains(layout)) {
      return HubRendererKind.editorial;
    }
    return HubRendererKind.horizontalCards;
  }
}
