import bpy

class test_panel(bpy.types.Panel):
    bl_label = "test_panel"
    bl_idname = "PT_TestPanel"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "NewTab"

    def draw(self, contex):
        layout = self.layout
        row = layout.row()
        row.label(text="Sample Text", icon= "CUBE")
        row = layout.row()
        row.operator("mesh.primitive_cube_add")
        row = layout.row()
        row.operator("mesh.primitive_uv_sphere_add")


def register():
    bpy.utils.register_class(test_panel)

def unrigster():
    bpy.utils.unregister_class(test_panel)

if __name__ == "__main__":
    register()
