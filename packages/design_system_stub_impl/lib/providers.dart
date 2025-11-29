library design_system_stub_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'material_impl.dart' as material;
export 'notice_impl.dart'
    show materialNoticeOverrides, createMaterialNoticePresenter;

List<Override> get materialDesignOverrides => material.materialDesignOverrides;
