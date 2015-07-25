library dart_flex;

import 'dart:async';
import 'dart:core';
import 'dart:html';
import 'dart:html_common';
import 'dart:js';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:observe/observe.dart';

export 'package:observe/observe.dart';

part "src/components/accordion.dart";
part "src/components/button.dart";
part "src/components/color_box.dart";
part "src/components/combo_box.dart";
part "src/components/dart_flex_root_container.dart";
part "src/components/data_grid.dart";
part "src/components/data_grid_column.dart";
part "src/components/data_grid_item_renderer.dart";
part "src/components/drag_drop_area.dart";
part "src/components/editable_date.dart";
part "src/components/editable_date_time.dart";
part "src/components/editable_double.dart";
part "src/components/editable_int.dart";
part "src/components/editable_text.dart";
part "src/components/editable_text_area.dart";
part "src/components/editable_time.dart";
part "src/components/editable_time_extended.dart";
part "src/components/file_upload_button.dart";
part "src/components/flash_embed.dart";
part "src/components/footer.dart";
part "src/components/form.dart";
part "src/components/graphics.dart";
part "src/components/group.dart";
part "src/components/header.dart";
part "src/components/hgroup.dart";
part "src/components/image.dart";
part "src/components/item_renderer.dart";
part "src/components/list_renderer.dart";
part "src/components/list_base.dart";
part "src/components/repeater.dart";
part "src/components/rich_text.dart";
part "src/components/skinnable_component.dart";
part "src/components/slider.dart";
part "src/components/spacer.dart";
part "src/components/sprite_sheet.dart";
part "src/components/text_area.dart";
part "src/components/tile_group.dart";
part "src/components/toggle.dart";
part "src/components/ui_wrapper.dart";
part "src/components/vgroup.dart";
part "src/components/view_stack.dart";

part "src/core/class_factory.dart";
part "src/core/event_hook.dart";
part "src/core/frame_rate_manager.dart";
part "src/core/invalidation.dart";
part "src/core/layout.dart";
part "src/core/function_equality_util.dart";
part "src/core/reflow_manager.dart";
part "src/core/scroll_policy.dart";
part "src/core/skin_state.dart";
part "src/core/stream_subscription_manager.dart";
part "src/core/method_invoker.dart";

part "src/events/collection_event.dart";
part "src/events/framework_event.dart";
part "src/events/framework_event_dispatcher.dart";
part "src/events/view_stack_event.dart";

part "src/layout/absolute_layout.dart";
part "src/layout/base_layout.dart";
part "src/layout/horizontal_layout.dart";
part "src/layout/scroll_binder.dart";
part "src/layout/tile_layout.dart";
part "src/layout/vertical_layout.dart";

part "src/itemRenderers/accordion_header_item_renderer.dart";
part "src/itemRenderers/header_item_renderer.dart";
part "src/itemRenderers/editable_label_item_renderer.dart";
part "src/itemRenderers/label_item_renderer.dart";
part "src/itemRenderers/image_item_renderer.dart";

class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

class htmlInjectable {
  
  final String src;
  
  const htmlInjectable(this.src);
  
}

class Skin {
  
  final String src;
  
  const Skin(this.src);
  
}

int _NEXT_GUID = 1;

String getNextGUID() => 'uid_${_NEXT_GUID++}';