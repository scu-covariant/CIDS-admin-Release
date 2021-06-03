# Sichuan university Campus infomation distribution system administrater entrance
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (C) 2017-2021 Xiaochen Ma(马晓晨)
#
# Github:  @SunnyHaze
# Website: http://covscript.org.cn

import imgui
import imgui_font
import db_connector
import view_places
import images_func
import edit_backgrounds
var db = null
using imgui

system.file.remove("./imgui.ini")
var app=window_application(get_monitor_width(0),get_monitor_height(0),"四川大学壁纸信息分发系统管理员端")
# fonts
var font=add_font_extend_cn(imgui_font.source_han_sans, 32)
var large_font = add_font_extend_cn(imgui_font.source_han_sans, 54)
var tiny_font = add_font_extend_cn(imgui_font.source_han_sans,18)
# accounts
var account = ""
var password = ""
# window status
var if_login_window = true
var if_view_places = false
var if_login_success = false
var if_menu = false
var if_edit_backgrounds = false
var if_first_download = 5
# images
var scu_image =  load_bmp_image("images/sichuan.bmp")
var cov_image = load_bmp_image("images/cov.bmp")
var ins_image = load_bmp_image("images/ins.bmp")
var back_grounds = new array
function load_images()
    var res = db.exec("select picid,description from backgrounds order by picid")
    foreach i in res
        # system.out.println("bmp_cache/" + i[0].data + ".bmp")
        back_grounds.push_back({to_integer(i[0].data),load_bmp_image("bmp_cache/" + i[0].data + ".bmp"),i[1].data})
    end
end
# message
var pass_message = ""
#excption
var exception_string = ""
#data cache
set_font_scale(1.0) 

function login_success()
    if if_login_success
        open_popup("欢迎##popup登录")
    end
    if begin_popup_modal("欢迎##popup登录",if_login_success,{flags.no_move,flags.always_auto_resize})
        text("登录成功! 欢迎您 " + account + " ,正在下载数据..." )
        if if_first_download >= 2
            if_first_download--
            text("")
            end_popup() 
            return
        else
            if if_first_download == 1
                images_func.download_images()
                load_images()
                view_places.init(db,account,back_grounds)
                if_first_download--
            end
            if if_first_download == 0
                text("下载完成！")
                same_line()
                if button("确认##confirm_download")
                    if_login_success = false
                end    
                end_popup() 
            end
        end
    end
end

function menu()
    if if_menu
        begin_window("壁纸系统功能界面",if_menu,{flags.no_collapse,flags.no_move,flags.no_title_bar,flags.no_resize})
            # LATER
            # set_window_size(vec2(get_monitor_width(0)/4, get_monitor_height(0)/4 * 3))
            # set_window_pos(vec2(0,get_monitor_height(0)/4))
            if button("浏览全部教室")
                back_grounds.clear()
                load_images()
                if_view_places = true
                if_edit_backgrounds = false
            end
            if button("修改壁纸库")
                edit_backgrounds.init(db)
                if_edit_backgrounds = true
                if_view_places = false
            end
        end_window()
    end
end

function login_window() 
    if if_login_window
        var opened = true
        begin_window("壁纸信息分发系统登录",if_login_window,{flags.no_collapse,flags.no_resize,flags.no_move})
            var w = 580
            var h = 800
            set_window_size(vec2(w, h))
            set_window_pos(vec2((get_monitor_width(0)-w) / 2,(get_monitor_height(0)-h) / 2))
            text(" ")
            push_font(large_font)
            text("  欢迎使用四川大学壁纸分发系统")
            pop_font()
            separator()
            text(" ")
            text("                ")
            same_line()
            input_text("账户",account,10)
            text("                ")
            same_line()
            input_text_s("密码",password,30,{flags.password})
            text("                " + pass_message)
            text("                                                ")
            same_line()
            # 登录判定
            if button("登录系统##login")
                var res = db_connector.start(account,password)
                if typeid res == typeid string
                    open_popup("登录异常！##popup登录异常")
                    exception_string = res
                else
                    db = res
                    images_func.db = db
                    if_menu = true
                    if_login_window = false
                    if_login_success = true
                end
            end
            # LATER 图片有问题需要更新
            text(" ")
            text("                                   ") 
            same_line()
            image(scu_image,vec2(200,70))
            text(" ")
            text("                                     ") 
            same_line()
            image(cov_image,vec2(200,80))
            text(" ")
            text("                                               ") 
            same_line()
            image(ins_image,vec2(80,80))
            text("                                            ")
            same_line()  
            push_font(tiny_font)
            text("智锐科创计算机协会")
            # popups

            opened = true
            if begin_popup_modal("登录异常！##popup登录异常",opened,{flags.no_move,flags.always_auto_resize})
                text(exception_string)
                end_popup() 
            end
            pop_font()
        end_window()
    end
end

function campus_manager()
    if if_campus_manager
        begin_window("校区管理员界面",if_campus_manager,{flags.no_collapse,flags.no_move,flags.no_resize})
        if button("通过待审核的信息##commit")
            review_commit.read_db()
            if_review_commit = true
        end
        end_window()
    end
end

while !app.is_closed()
    app.prepare()
        style_color_light()
        push_font(font)
        # windows
        login_window()
        login_success()
        menu()
        if if_view_places 
            view_places.mywindow(if_view_places)
        end
        if if_edit_backgrounds
            edit_backgrounds.start(if_edit_backgrounds,back_grounds)
        end
        pop_font()    
    app.render()
end
