<title>WireGuard</title>
<content>
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/js/tomato.js"></script>
<script type="text/javascript" src="/js/advancedtomato.js"></script>
<style type="text/css">
.box, #wireguard_tabs {
	min-width:720px;
}
</style>
	<script type="text/javascript">
		var dbus;
		get_arp_list();
		get_conf_list();
		get_wan_list();
		get_dbus_data();
		var _responseLen;
		var noChange = 0;
		var x = 4;
		var status_time = 1;
		var option_acl_mode = [['0', '不代理'], ['1', 'gfwlist黑名单'], ['2', '大陆白名单'], ['3', '全局模式']];
		var option_acl_mode_name = ['不代理', 'gfwlist黑名单', '大陆白名单', '全局模式'];
		var option_acl_port = [['80,443', '80,443'], ['22,80,443', '22,80,443'], ['all', '全部端口'],['0', '自定义']];
		var option_acl_port_name = ['80,443', '22,80,443', '全部端口', '自定义'];
		var option_arp_list = [];
		var option_arp_local = [];
		var option_arp_web = [];
		var option_conf_local = [];
		var option_file = [];
		var softcenter = 0;
		var option_day_time = [["7", "每天"], ["1", "周一"], ["2", "周二"], ["3", "周三"], ["4", "周四"], ["5", "周五"], ["6", "周六"], ["0", "周日"]];
		var option_hour_time = [];
		for(var i = 0; i < 24; i++){
			option_hour_time[i] = [i, i + "点"];
		}

		if (typeof btoa == "Function") {
			Base64 = {
				encode: function(e) {
					return btoa(e);
				},
				decode: function(e) {
					return atob(e);
				}
			};
		} else {
			Base64 = {
				_keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
				encode: function(e) {
					var t = "";
					var n, r, i, s, o, u, a;
					var f = 0;
					e = Base64._utf8_encode(e);
					while (f < e.length) {
						n = e.charCodeAt(f++);
						r = e.charCodeAt(f++);
						i = e.charCodeAt(f++);
						s = n >> 2;
						o = (n & 3) << 4 | r >> 4;
						u = (r & 15) << 2 | i >> 6;
						a = i & 63;
						if (isNaN(r)) {
							u = a = 64
						} else if (isNaN(i)) {
							a = 64
						}
						t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
					}
					return t
				},
				decode: function(e) {
					var t = "";
					var n, r, i;
					var s, o, u, a;
					var f = 0;
					if (typeof(e) == "undefined"){
						return t = "";
					}
					e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
					while (f < e.length) {
						s = this._keyStr.indexOf(e.charAt(f++));
						o = this._keyStr.indexOf(e.charAt(f++));
						u = this._keyStr.indexOf(e.charAt(f++));
						a = this._keyStr.indexOf(e.charAt(f++));
						n = s << 2 | o >> 4;
						r = (o & 15) << 4 | u >> 2;
						i = (u & 3) << 6 | a;
						t = t + String.fromCharCode(n);
						if (u != 64) {
							t = t + String.fromCharCode(r)
						}
						if (a != 64) {
							t = t + String.fromCharCode(i)
						}
					}
					t = Base64._utf8_decode(t);
					return t
				},
				_utf8_encode: function(e) {
					e = e.replace(/\r\n/g, "\n");
					var t = "";
					for (var n = 0; n < e.length; n++) {
						var r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r)
						} else if (r > 127 && r < 2048) {
							t += String.fromCharCode(r >> 6 | 192);
							t += String.fromCharCode(r & 63 | 128)
						} else {
							t += String.fromCharCode(r >> 12 | 224);
							t += String.fromCharCode(r >> 6 & 63 | 128);
							t += String.fromCharCode(r & 63 | 128)
						}
					}
					return t
				},
				_utf8_decode: function(e) {
					var t = "";
					var n = 0;
					var r = c1 = c2 = 0;
					while (n < e.length) {
						r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r);
							n++
						} else if (r > 191 && r < 224) {
							c2 = e.charCodeAt(n + 1);
							t += String.fromCharCode((r & 31) << 6 | c2 & 63);
							n += 2
						} else {
							c2 = e.charCodeAt(n + 1);
							c3 = e.charCodeAt(n + 2);
							t += String.fromCharCode((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
							n += 3
						}
					}
					return t
				}
			}
		}
		function createFormFields(data, settings) {
			var id, id1, common, output, form = '';
			var s = $.extend({
					// Defaults
					'align': 'left',
					'grid': ['col-sm-3', 'col-sm-9']
				},
				settings);
			// Loop through array
			$.each(data,
				function(key, v) {
					if (!v) {
						form += '<br />';
						return;
					}
					if (v.ignore) return;
					form += '<fieldset' + ((v.rid) ? ' id="' + v.rid + '"' : '') + ((v.hidden) ? ' style="display: none;"' : '') + '>';
					if (v.help) {
						v.title += ' (<i data-toggle="tooltip" class="icon-info icon-normal" title="' + v.help + '"></i>)';
					}
					if (v.text) {
						if (v.title) {
							form += '<label class="' + s.grid[0] + ' ' + ((s.align == 'center') ? 'control-label' : 'control-left-label') + '">' + v.title + '</label><div class="' + s.grid[1] + ' text-block">' + v.text + '</div></fieldset>';
						} else {
							form += '<label class="' + s.grid[0] + ' ' + ((s.align == 'center') ? 'control-label' : 'control-left-label') + '">' + v.text + '</label></fieldset>';
						}
						return;
					}
					if (v.multi) multiornot = v.multi;
					else multiornot = [v];
					output = '';
					$.each(multiornot,
						function(key, f) {
							if ((f.type == 'radio') && (!f.id)) id = '_' + f.name + '_' + i;
							else id = (f.id ? f.id : ('_' + f.name));
							if (id1 == '') id1 = id;
							common = ' onchange="verifyFields(this, 1)" id="' + id + '"';
							if (f.size > 65) common += ' style="width: 100%; display: block;"';
							if (f.hidden) common += ' style="display:none;"'; //add by sadog
							if (f.attrib) common += ' ' + f.attrib;
							name = f.name ? (' name="' + f.name + '"') : '';
							// Prefix
							if (f.prefix) output += f.prefix;
							switch (f.type) {
								case 'checkbox':
									output += '<div class="checkbox c-checkbox"><label><input class="custom" type="checkbox"' + name + (f.value ? ' checked' : '') + ' onclick="verifyFields(this, 1)"' + common + '>\
		<span></span> ' + (f.suffix ? f.suffix : '') + '</label></div>';
									break;
								case 'radio':
									output += '<div class="radio c-radio"><label><input class="custom" type="radio"' + name + (f.value ? ' checked' : '') + ' onclick="verifyFields(this, 1)"' + common + '>\
		<span></span> ' + (f.suffix ? f.suffix : '') + '</label></div>';
									break;
								case 'password':
									if (f.peekaboo) {
										switch (get_config('web_pb', '1')) {
											case '0':
												f.type = 'text';
											case '2':
												f.peekaboo = 0;
												break;
										}
									}
									if (f.type == 'password') {
										common += ' autocomplete="off"';
										if (f.peekaboo) common += ' onfocus=\'peekaboo("' + id + '",1)\' onclick=\'this.removeAttribute(' + 'readonly' + ');\' readonly="true"';
									}
									// drop
								case 'text':
									output += '<input type="' + f.type + '"' + name + ' value="' + escapeHTML(UT(f.value)) + '" maxlength=' + f.maxlen + (f.size ? (' size=' + f.size) : '') + (f.style ? (' style=' + f.style) : '') + (f.onblur ? (' onblur=' + f.onblur) : '') + common + '>';
									break;
								case 'select':
									output += '<select' + name + (f.style ? (' style=' + f.style) : '') + common + '>';
									for (optsCount = 0; optsCount < f.options.length; ++optsCount) {
										a = f.options[optsCount];
										if (a.length == 1) a.push(a[0]);
										output += '<option value="' + a[0] + '"' + ((a[0] == f.value) ? ' selected' : '') + '>' + a[1] + '</option>';
									}
									output += '</select>';
									break;
								case 'textarea':
									output += '<textarea ' + 'spellcheck=\"false\"' + (f.style ? (' style="' + f.style + '" ') : '') + name + common + (f.wrap ? (' wrap=' + f.wrap) : '') + '>' + escapeHTML(UT(f.value)) + '</textarea>';
									break;
								default:
									if (f.custom) output += f.custom;
									break;
							}
							if (f.suffix && (f.type != 'checkbox' && f.type != 'radio')) output += '<span class="help-block">' + f.suffix + '</span>';
						});
					if (id1 != '') form += '<label class="' + s.grid[0] + ' ' + ((s.align == 'center') ? 'control-label' : 'control-left-label') + '" for="' + id + '">' + v.title + '</label><div class="' + s.grid[1] + '">' + output;
					else form += '<label>' + v.title + '</label>';
					form += '</div></fieldset>';
				});
			return form;
		}
		//============================================
		var wireguard_acl = new TomatoGrid();
		wireguard_acl.dataToView = function( data ) {
			var option_acl_port = [['80,443', '80,443'], ['22,80,443', '22,80,443'], ['all', 'all'], ['0', '自定义']];
			var option_acl_port_value = ['80,443', '22,80,443', 'all', '0'];
			var option_acl_port_name = ['80,443', '22,80,443', '全部端口', '自定义'];
			var a = option_acl_port_value.indexOf(data[4]);
			var b = option_acl_port_name[a]
			if (data[4] == 0){
				b = data[5]
			}
		
			if (data[0]){
				return [ "【" + data[0] + "】", data[1], data[2], option_acl_mode_name[data[3]], b, data[5] ];
			}else{
				if (data[1]){
					return [ "【" + data[1] + "】", data[1], data[2], option_acl_mode_name[data[3]], b, data[5] ];
				}else{
					if (data[2]){
						return [ "【" + data[2] + "】", data[1], data[2], option_acl_mode_name[data[3]], b, data[5] ];
					}
				}
			}
		}
		wireguard_acl.fieldValuesToData = function( row ) {
			var f = fields.getAll( row );
			if (f[0].value){
				return [ f[0].value, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value ];
			}else{
				if (f[1].value){
					return [ f[1].value, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value ];
				}else{
					if (f[2].value){
						return [ f[2].value, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value ];
					}
				}
			}
		}
		wireguard_acl.dataToFieldValues = function (data) {
			return [data[0], data[1], data[2], data[3], data[4], data[5]];
		}
    	wireguard_acl.onChange = function(which, cell) {
    	    return this.verifyFields((which == 'new') ? this.newEditor: this.editor, true, cell);
    	}
		wireguard_acl.verifyFields = function( row, quiet,cell ) {
			var f = fields.getAll( row );
			// fill the ip and mac when chose the name
			if ( $(cell).attr("id") == "_[object HTMLTableElement]_1" ) {
				if (f[0].value){
					f[1].value = option_arp_list[f[0].selectedIndex][2];
					f[2].value = option_arp_list[f[0].selectedIndex][3];
				}
			}

			// user port
			if (f[4].selectedIndex == 3){
				$("#wireguard_acl_pannel > tbody > tr > td:nth-child(6)").show();
				$("#_wireguard_acl_pannel_6").show();
			}else{
				$("#wireguard_acl_pannel > tbody > tr > td:nth-child(6)").hide();
				$("#_wireguard_acl_pannel_6").hide();
			}
			//check if ip and mac column correct
			if (f[1].value && !f[2].value){
				return v_ip( f[1], quiet );
			}
			if (!f[1].value && f[2].value){
				return v_mac( f[2], quiet );
			}
			if (f[1].value && f[2].value){
				return v_ip( f[1], quiet ) || v_mac( f[2], quiet );
			}
		}
		wireguard_acl.alter_txt = function() {
			if (this.tb.rows.length == "6"){
				$('#footer_ip').html("<i>全部主机 - ip</i>")
				$('#footer_mac').html("<i>全部主机 - mac</i>")
			}else{
				$('#footer_ip').html("<i>其它主机 - ip</i>")
				$('#footer_mac').html("<i>其它主机 - mac</i>")
			}
		}
		wireguard_acl.onAdd = function() {
			var data;
			this.moving = null;
			this.rpHide();
			if (!this.verifyFields(this.newEditor, false)) return;
			data = this.fieldValuesToData(this.newEditor);
			this.insertData(1, data);
			this.disableNewEditor(false);
			this.resetNewEditor();
			this.alter_txt(); // added by sadog
		}
		wireguard_acl.rpDel = function(b) {
			b = PR(b);
			TGO(b).moving = null;
			b.parentNode.removeChild(b);
			this.recolor();
			this.rpHide()
			this.alter_txt(); // added by sadog
		}
		wireguard_acl.resetNewEditor = function() {
			var f;
			f = fields.getAll( this.newEditor );
			ferror.clearAll( f );
			f[ 0 ].value = '';
			f[ 1 ].value   = '';
			f[ 2 ].value   = '';
			f[ 3 ].value   = '1';
			f[ 4 ].value   = '80,443';
			f[ 5 ].value   = '';
		}
		wireguard_acl.footerSet = function(c, b) {
			var f, d;
			elem.remove(this.footer);
			this.footer = f = this._insert(-1, c, b);
			//f.className = "alert alert-info";
			for (d = 0; d < f.cells.length; ++d) {
				f.cells[d].cellN = d;
				f.cells[d].onclick = function() {
					TGO(this).footerClick(this)
				}
			}
			return f
		}
		wireguard_acl.setup = function() {
			this.init( 'wireguard_acl_pannel', '', 254, [
			{ type: 'select',maxlen:20,options:option_arp_list},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'select',maxlen:20,options:option_acl_mode},	//control
			{ type: 'select',maxlen:20,options:option_acl_port},
			{ type: 'text',maxlen:20}
			] );
			this.headerSet( [ '主机别名', '主机IP地址', 'MAC地址', '访问控制', '目标端口', '自定义端口'] );
			if (typeof(dbus["wireguard_acl_node_max"]) == "undefined"){
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>全部主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>全部主机 - mac</small></i>','<select id="_wireguard_acl_default_mode1" name="wireguard_acl_default_mode1" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;" onchange="verifyFields(this, 1)"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">全局模式</option></select>','<small id="footer_port" style="color:#1bbf35"><i>全部主机 - 全部端口</i></small>','<small id="footer_port_user" style="color:#1bbf35"></small>']);
			}else{
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>其它主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>其它主机 - mac</small></i>','<select id="_wireguard_acl_default_mode1" name="wireguard_acl_default_mode1" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;" onchange="verifyFields(this, 1)"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">全局模式</option></select>','<small id="footer_port" style="color:#1bbf35"><i>其它主机 - 全部端口</i></small>','<small id="footer_port_user" style="color:#1bbf35"></small>']);
			}
			
			if(typeof(dbus["wireguard_acl_default_mode"]) != "undefined" ){
				E("_wireguard_acl_default_mode1").value = dbus["wireguard_acl_default_mode"];
			}else{
				E("_wireguard_acl_default_mode1").value = 1;
			}
			
			for ( var i = 1; i <= dbus["wireguard_acl_node_max"]; i++){
				var t = [dbus["wireguard_acl_name_" + i ], 
						dbus["wireguard_acl_ip_" + i ]  || "",
						dbus["wireguard_acl_mac_" + i ]  || "",
						dbus["wireguard_acl_mode_" + i ],
						dbus["wireguard_acl_port_" + i ],
						dbus["wireguard_acl_port_user_" + i ]||""
						]
				if ( t.length == 6 ) this.insertData( -1, t );
			}
			this.recolor();
			this.showNewEditor();
			this.resetNewEditor();
		}
		//============================================
		function init_wireguard(){
			tabSelect('app1');
			verifyFields();
			$("#_wireguard_basic_log").click(
				function() {
					x = 10000000;
			});
			show_hide_panel();
			set_version();
			//version_show();
			setTimeout("get_run_status();", 2000);
		}

		function get_arp_list(){
			var id5 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id5, "method": "wireguard_getarp.sh", "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async:true,
				cache:false,
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if (response.result != "-1"){
						var s2 = response.result.split( '>' );
						for ( var i = 0; i < s2.length; ++i ) {
							option_arp_local[i] = [s2[ i ].split( '<' )[0], "【" + s2[ i ].split( '<' )[0] + "】", s2[ i ].split( '<' )[1]];
						}
						var node_acl = parseInt(dbus["wireguard_acl_node_max"]) || 0;
						for ( var i = 0; i < node_acl; ++i ) {
							option_arp_web[i] = [dbus["wireguard_acl_name_" + (i + 1)], "【" + dbus["wireguard_acl_name_" + (i + 1)] + "】", dbus["wireguard_acl_ip_" + (i + 1)]];
						}			
						option_arp_list = unique_array(option_arp_local.concat( option_arp_web ));
						wireguard_acl.setup();
					}
				},
				error:function(){
					wireguard_acl.setup();
				},
				timeout:1000
			});
		}

		function unique_array(array){
			var r = [];
			for(var i = 0, l = array.length; i < l; i++) {
				for(var j = i + 1; j < l; j++)
				if (array[i][0] === array[j][0]) j = ++i;
					r.push(array[i]);
			}
			return r.sort();;
		}

		function set_version(){
			$('#_wireguard_version').html( '<font color="#1bbf35">WireGuard for openwrt - ' + (dbus["wireguard_version"]  || "") + '</font>' );
		}

		function get_dbus_data(){
			$.ajax({
			  	type: "GET",
			 	url: "/_api/wireguard_",
			  	dataType: "json",
			  	async:false,
			 	success: function(data){
			 	 	dbus = data.result[0];
					//conf2obj();
			  	}
			});
		}
		
		function get_run_status(){
			if (status_time > 99999){
				E("_wireguard_basic_status_foreign").innerHTML = "暂停获取状态...";
				E("_wireguard_basic_status_china").innerHTML = "暂停获取状态...";
				return false;
			}
			var id1 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id1, "method": "wireguard_status.sh", "params":[2], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if(softcenter == 1){
						return false;
					}
					++status_time;
					if (response.result == '-2'){
						E("_wireguard_basic_status_foreign").innerHTML = "获取运行状态失败！";
						E("_wireguard_basic_status_china").innerHTML = "获取运行状态失败！";
						setTimeout("get_run_status();", 5000);
					}else{
						if(dbus["wireguard_basic_enable"] != "1"){
							E("_wireguard_basic_status_foreign").innerHTML = "国外链接 - 尚未提交，暂停获取状态！";
							E("_wireguard_basic_status_china").innerHTML = "国内链接 - 尚未提交，暂停获取状态！";
						}else{
							E("_wireguard_basic_status_foreign").innerHTML = response.result.split("@@")[0];
							E("_wireguard_basic_status_china").innerHTML = response.result.split("@@")[1];
						}
						setTimeout("get_run_status();", 5000);
					}
				},
				error: function(){
					if(softcenter == 1){
						return false;
					}
					E("_wireguard_basic_status_foreign").innerHTML = "获取运行状态失败！";
					E("_wireguard_basic_status_china").innerHTML = "获取运行状态失败！";
					setTimeout("get_run_status();", 5000);
				}
			});
		}

		function get_conf_list(){
			var id6 = parseInt(Math.random() * 100000000);
			var postData9 = {"id": id6, "method": "wireguard_getconf.sh", "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async:true,
				cache:false,
				data: JSON.stringify(postData9),
				dataType: "json",
				success: function(response){
					if (response.result != "-1"){
						var s3 = response.result.split( '>' );
						//console.log(s3);
						$("#_wireguard_basic_conf").append("<option value = 0>" + "自定义配置文件" + "</option>");
						for ( var i = 0; i < s3.length; ++i ) {							
							$("#_wireguard_basic_conf").append("<option value='" + s3[i] + "'>" + s3[i] + "</option>");
						}
					}
					conf2obj_conf();
				},
				timeout:1000
			});
		}

		function get_wan_list(){
			var id2 = parseInt(Math.random() * 100000000);
			var postData2 = {"id": id2, "method": "wireguard_getwan.sh", "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async:true,
				cache:false,
				data: JSON.stringify(postData2),
				dataType: "json",
				success: function(response){
					if (response.result != "-1"){
						var s2 = response.result.split( '>' );
						//console.log(s3);
						for ( var i = 0; i < s2.length; ++i ) {							
							$("#_wireguard_basic_vpn").append("<option value='" + s2[i] + "'>" + s2[i] + "</option>");
						}
						conf2obj_vpn();
					}
				},
				timeout:1000
			});
		}

		function conf2obj_vpn(){
			E("_wireguard_basic_vpn").value = dbus["wireguard_basic_vpn"];
		}

		function conf2obj_conf(){
			E("_wireguard_basic_conf").value = dbus["wireguard_basic_conf"];
		}

		function unique_array(array){
			var r = [];
			for(var i = 0, l = array.length; i < l; i++) {
				for(var j = i + 1; j < l; j++)
				if (array[i][0] === array[j][0]) j = ++i;
					r.push(array[i]);
			}
			return r.sort();;
		}

		function show_hide_panel(){
			var a  = E('_wireguard_basic_enable').checked;
			elem.display('wireguard_status_pannel', a);
			elem.display('wireguard_tabs', a);
			elem.display('wireguard_basic_tab', a);
		}

		function verifyFields(r){
			// when check/uncheck wireguard_switch
			var a  = E('_wireguard_basic_enable').checked;
			if ( $(r).attr("id") == "_wireguard_basic_enable" ) {
				if(a){
					elem.display('wireguard_status_pannel', a);
					elem.display('wireguard_tabs', a);
					tabSelect('app1')
				}else{
					tabSelect('fuckapp')
				}
			}
			// change main mode adn acl mode
			if ( $(r).attr("id") == "_wireguard_acl_default_mode" ) {
				E("_wireguard_acl_default_mode1").value = E("_wireguard_acl_default_mode").value;
			}
			if ( $(r).attr("id") == "_wireguard_acl_default_mode1" ) {
				E("_wireguard_acl_default_mode").value = E("_wireguard_acl_default_mode1").value;
			}
			//config
			var d  = E('_wireguard_basic_conf').value == '0';
			elem.display(PR('_wireguard_custom_config'), d);

			return true;
		}
		function tabSelect(obj){
			var tableX = ['app1-tab', 'app2-tab','app3-tab','app4-tab','app5-tab','app6-tab','app7-tab'];
			var boxX = ['boxr1','boxr2','boxr3','boxr4','boxr5','boxr6','boxr7'];
			var appX = ['app1','app2','app3','app4','app5','app6','app7'];
			for (var i = 0; i < tableX.length; i++){
				if(obj == appX[i]){
					$('#'+tableX[i]).addClass('active');
					$('.'+boxX[i]).show();
				}else{
					$('#'+tableX[i]).removeClass('active');
					$('.'+boxX[i]).hide();
				}
			}
			if(obj=='app6'){
				elem.display('save-button', false);
				noChange=0;
				setTimeout("get_log();", 200);
			}else{
				elem.display('save-button', true);
				noChange=2001;
			}
			if(obj=='fuckapp'){
				elem.display('wireguard_status_pannel', false);
				elem.display('wireguard_tabs', false);
				elem.display('wireguard_basic_tab', false);
				elem.display('wireguard_wblist_tab', false);
				elem.display('wireguard_acl_tab', false);
				elem.display('wireguard_addon_tab', false);
				elem.display('wireguard_log_tab', false);
				E('save-button').style.display = "";
			}
		}

		function showMsg(Outtype, title, msg){
			$('#'+Outtype).html('<h5>'+title+'</h5>'+msg+'<a class="close"><i class="icon-cancel"></i></a>');
			$('#'+Outtype).show();
		}

		function save(){
			status_time = 999999990;
			setTimeout("tabSelect('app6')", 500);
			//get_run_status();
			E("_wireguard_basic_status_foreign").innerHTML = "国外链接 - 提交中...暂停获取状态！";
			E("_wireguard_basic_status_china").innerHTML = "国内链接 - 提交中...暂停获取状态！";
			var paras_chk = ["enable", "keepalive"];
			var paras_inp = ["wireguard_acl_default_mode", "wireguard_basic_conf", "wireguard_basic_vpn"];
			// collect data from checkbox
			for (var i = 0; i < paras_chk.length; i++) {
				dbus["wireguard_basic_" + paras_chk[i]] = E('_wireguard_basic_' + paras_chk[i] ).checked ? '1':'0';
			}
			// data from other element
			for (var i = 0; i < paras_inp.length; i++) {
				if (typeof(E('_' + paras_inp[i] ).value) == "undefined"){
					dbus[paras_inp[i]] = "";
				}else{
					dbus[paras_inp[i]] = E('_' + paras_inp[i]).value;
				}
			}
			// data need base64 encode
			var paras_base64 = ["wireguard_wan_white_ip", "wireguard_wan_white_domain", "wireguard_wan_black_ip", "wireguard_wan_black_domain"];
			for (var i = 0; i < paras_base64.length; i++) {
				if (typeof(E('_' + paras_base64[i] ).value) == "undefined"){
					dbus[paras_base64[i]] = "";
				}else{
					dbus[paras_base64[i]] = Base64.encode(E('_' + paras_base64[i]).value);
				}
			}
			dbus["wireguard_custom_config"] = Base64.encode(E('_wireguard_custom_config').value);
			// collect acl data from acl pannel
			var wireguard_acl_conf = ["wireguard_acl_name_", "wireguard_acl_ip_", "wireguard_acl_mac_", "wireguard_acl_mode_", "wireguard_acl_port_", "wireguard_acl_port_user_" ];
			// mark all acl data for delete first
			for ( var i = 1; i <= dbus["wireguard_acl_node_max"]; i++){
				for ( var j = 0; j < wireguard_acl_conf.length; ++j ) {
					dbus[wireguard_acl_conf[j] + i ] = ""
				}
			}
			var data2 = wireguard_acl.getAllData();
			if(data2.length > 0){
				for ( var i = 0; i < data2.length; ++i ) {
					for ( var j = 1; j < wireguard_acl_conf.length; ++j ) {
						dbus[wireguard_acl_conf[0] + (i + 1)] = data2[i][0];
						dbus[wireguard_acl_conf[j] + (i + 1)] = data2[i][j];
					}
				}
				dbus["wireguard_acl_node_max"] = data2.length;
			}else{
				dbus["wireguard_acl_node_max"] = "";
			}
			
			// now post data
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "wireguard_config.sh", "params":[1], "fields": dbus};
			showMsg("msg_warring","正在提交数据！","<b>等待后台运行完毕，请不要刷新本页面！</b>");
			$.ajax({
				url: "/_api/",
				type: "POST",
				async:true,
				cache:false,
				dataType: "json",
				data: JSON.stringify(postData),
				success: function(response){
					if (response.result == id){
						if(E('_wireguard_basic_enable').checked){
							showMsg("msg_success","提交成功","<b>成功提交数据</b>");
							$('#msg_warring').hide();
							setTimeout("$('#msg_success').hide()", 500);
							x = 4;
							count_down_switch();
						}else{
							// when shut down ss finished, close the log tab
							$('#msg_warring').hide();
							showMsg("msg_success","提交成功","<b>wireguard成功关闭！</b>");
							setTimeout("$('#msg_success').hide()", 4000);
							setTimeout("tabSelect('fuckapp')", 4000);
						}
					}else{
						$('#msg_warring').hide();
						showMsg("msg_error","提交失败","<b>提交数据失败！错误代码：" + response.result + "</b>");
						setTimeout("window.location.reload()", 500);
					}
				},
				error: function(){
					showMsg("msg_error","失败","<b>当前系统存在异常查看系统日志！</b>");
					status_time = 1;
				}
			});
		}

		function get_log(){
			$.ajax({
				url: '/_temp/wireguard_log.txt',
				type: 'GET',
				dataType: 'html',
				async: true,
				cache:false,
				success: function(response) {
					var retArea = E("_wireguard_basic_log");
					if (response.search("XU6J03M6") != -1) {
						retArea.value = response.replace("XU6J03M6", " ");
						retArea.scrollTop = retArea.scrollHeight;
						return true;
					}
					if (_responseLen == response.length) {
						noChange++;
					} else {
						noChange = 0;
					}
					if (noChange > 2000) {
						//tabSelect("app1");
						return false;
					} else {
						setTimeout("get_log();", 100); //100 is radical but smooth!
					}
					retArea.value = response;
					retArea.scrollTop = retArea.scrollHeight;
					_responseLen = response.length;
				},
				error: function() {
					E("_wireguard_basic_log").value = "获取日志失败！";
				}
			});
		}
		function count_down_switch() {
			if (x == "0") {
				setTimeout("window.location.reload()", 500);
			}
			if (x < 0) {
				return false;
			}
				--x;
			setTimeout("count_down_switch();", 500);
		}
		function manipulate_conf(script, arg){
			var dbus3 = {};
			if(arg == 2 || arg == 3){
				tabSelect("app6");
			}else if(arg == 6){
				status_time = 999999990;
				get_run_status();
				tabSelect("app6");
			}
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": script, "params":[arg], "fields": dbus3 };
			$.ajax({
				type: "POST",
				url: "/_api/",
				async: true,
				cache:false,
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response){
					if (script == "wireguard_config.sh"){
						if(arg == 2 || arg == 4 || arg == 6 || arg == 5 || arg == 7 ){
							setTimeout("window.location.reload()", 800);
						}else if (arg == 3){
							var a = document.createElement('A');
							a.href = "/files/wireguard_conf_backup.sh";
							a.download = 'wireguard_conf_backup.sh';
							document.body.appendChild(a);
							a.click();
							document.body.removeChild(a);
						}else if (arg == 5 || arg == 9 ){
							setTimeout("tabSelect('app6')", 500);
							setTimeout("window.location.reload()", 800);
						}
					}
				}
			});
		}
		function restore_conf(){
			var filename = $("#file").val();
			filename = filename.split('\\');
			filename = filename[filename.length-1];
			var filelast = filename.split('.');
			filelast = filelast[filelast.length-1];
			if(filelast !='sh'){
				alert('配置文件格式不正确！');
				return false;
			}
			var formData = new FormData();
			formData.append('wireguard_conf_backup.sh', $('#file')[0].files[0]);
			$('.popover').html('正在恢复，请稍后……');
			//changeButton(true);
			$.ajax({
				url: '/_upload',
				type: 'POST',
				async: true,
				cache:false,
				data: formData,
				processData: false,
				contentType: false,
				complete:function(res){
					if(res.status==200){
						manipulate_conf('wireguard_config.sh', 4);
					}
				}
			});
		}

		function upload_conf(){
			var filename = $("#file2").val();
			filename = filename.split('\\');
			filename = filename[filename.length-1];
			var filelast = filename.split('.');
			filelast = filelast[filelast.length-1];
			if(filelast !='conf'){
				alert('配置文件格式不正确！');
				return false;
			}
			var formData = new FormData();
			formData.append(filename + '.wireguardconfig', $('#file2')[0].files[0]);
			$('.popover').html('正在上传，请稍后……');
			//changeButton(true);
			$.ajax({
				url: '/_upload',
				type: 'POST',
				async: true,
				cache:false,
				data: formData,
				processData: false,
				contentType: false,
				complete:function(res){
					if(res.status==200){
						manipulate_conf('wireguard_config.sh', 9);
					}
				}
			});
		}

		function del_conf(){
			var para_inp = ["wireguard_basic_conf"];
			// data from other element
			for (var i = 0; i < para_inp.length; i++) {
				if (!E('_' + para_inp[i] ).value){
					dbus[para_inp[i]] = "";
				}else{
					dbus[para_inp[i]] = E('_' + para_inp[i]).value;
				}
			}
			// post data
			var id5 = parseInt(Math.random() * 100000000);
			var postData5 = {"id": id5, "method": "wireguard_config.sh", "params":[5], "fields": dbus};
			$('.popover').html('正在删除，请稍后……');
			//changeButton(true);
			$.ajax({
				url: "/_api/",
				cache:false,
				type: "POST",
				dataType: "json",
				data: JSON.stringify(postData5),
				success: function(response){
					if (response.result == id5){
							showMsg("msg_success","成功","<b>配置文件已成功删除！</b>");
							setTimeout("$('#msg_success').hide()", 4000);
							setTimeout("window.location.reload()", 500);
					}else{
						$('#msg_warring').hide();
						showMsg("msg_error","提交失败","<b>提交数据失败！错误代码：" + response.result + "</b>");
						setTimeout("window.location.reload()", 500);
					}
				},
				error: function(){
					showMsg("msg_error","失败","<b>当前系统存在异常查看系统日志！</b>");
				}
			});
		}

		function version_show() {
			$('#_wireguard_version').html( '<font color="#1bbf35">WireGuard for openwrt - ' + (dbus["wireguard_version"]  || "") + '</font>' );
			$.ajax({
				url: 'https://raw.githubusercontent.com/koolshare/ledesoft/master/wireguard/config.json.js',
				type: 'GET',
				dataType: 'json',
				success: function(res) {
					if (typeof(res["version"]) != "undefined" && typeof(dbus["wireguard_version"]) != "undefined" && res["version"].length > 0 && res["version"] != dbus["wireguard_version"]) {
						$("#updateBtn").html('升级到：' + res.version);
					}
				}
			});
		}		
	</script>
	<div class="box">
		<div class="heading">
			<span id="_wireguard_version"></span>
			<a href="#/soft-center.asp" class="btn" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">返回</a>
			<a href="https://github.com/koolshare/ledesoft/blob/master/wireguard/Changelog.txt" target="_blank" class="btn btn-primary" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">更新日志</a>
			<!--<button type="button" id="updateBtn" onclick="check_update()" class="btn btn-primary" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">检查更新 <i class="icon-upgrade"></i></button>-->
		</div>
		<div class="content">
			<span class="col" style="line-height:30px;width:700px">
			WireGuard 使用UDP协议传输数据，作为Linux内核模块运行，使用了最先进的加密技术，支持IP地址漫游，被视为下一代VPN协议。<br />
			WireGuard 可同时作为服务器端和客户端使用<a href="https://www.wireguard.com/" target="_blank"> 【点此访问主页】 </a><a href="https://tunsafe.com/vpn" target="_blank"> 【免费服务器】 </a>
		</div>
	</div>
	<div class="box" style="margin-top: 0px;">
		<div class="heading">
		</div>
		<div class="content">
			<div id="wireguard_switch_pannel" class="section" style="margin-top: -20px;"></div>
			<script type="text/javascript">
				$('#wireguard_switch_pannel').forms([
					{ title: '代理开关', name:'wireguard_basic_enable',type:'checkbox',  value: dbus.wireguard_basic_enable == 1 }  // ==1 means default close; !=0 means default open
				]);
			</script>
			<hr />
			<fieldset id="wireguard_status_pannel">
				<label class="col-sm-3 control-left-label" for="_undefined">代理运行状态</label>
				<div class="col-sm-9">
					<font id="_wireguard_basic_status_foreign" name="wireguard_basic_status_foreign" color="#1bbf35">国外链接: waiting...</font>
				</div>
				<div class="col-sm-9" style="margin-top:2px">
					<font id="_wireguard_basic_status_china" name="wireguard_basic_status_china" color="#1bbf35">国内链接: waiting...</font>
				</div>
			</fieldset>
		</div>
	</div>
	<ul id="wireguard_tabs" class="nav nav-tabs">
		<li><a href="javascript:void(0);" onclick="tabSelect('app1');" id="app1-tab" class="active"><i class="icon-system"></i> 帐号设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app2');" id="app2-tab"><i class="icon-warning"></i> 黑白名单</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app3');" id="app3-tab"><i class="icon-tools"></i> 访问控制</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app5');" id="app5-tab"><i class="icon-wake"></i> 附加设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app6');" id="app6-tab"><i class="icon-hourglass"></i> 查看日志</a></li>	
	</ul>
	<div class="box boxr1" id="wireguard_basic_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="wireguard_basic_pannel" class="section"></div>
			<script type="text/javascript">
				$('#wireguard_basic_pannel').forms([
					{ title: '代理模式', name:'wireguard_acl_default_mode',type:'select', options:option_acl_mode, value:dbus.wireguard_acl_default_mode },
					{ title: 'VPN出口', name:'wireguard_basic_vpn',type:'select', options:[], value:dbus.wireguard_basic_vpn },
					{ title: '配置文件上传', suffix: '<input type="file" id="file2" size="50">&nbsp;&nbsp;<button id="uploadconfig" type="button"  onclick="upload_conf();" class="btn btn-success">上传 </button>' },
					{ title: '配置文件选择', multi: [ 
						{ name:'wireguard_basic_conf',type:'select',options:[], value:dbus.wireguard_basic_conf },
						{ suffix: '<button id="delconfig" type="button"  onclick="del_conf();" class="btn btn-danger">删除 </button>' },
					]},
					{ title: '保持连接', name:'wireguard_basic_keepalive',type:'checkbox',  value: dbus.wireguard_basic_keepalive == 1 , suffix: '<lable>在配置文件中增加PersistentKeepalive项设置心跳间隔，单位：秒</lable>'},
					{ title: 'wireguard自定义配置文件', name:'wireguard_custom_config',type:'textarea', value: Base64.decode(dbus.wireguard_custom_config)||"", style: 'width: 100%; height:450px;' },
				]);
			</script>
		</div>
	</div>
	<!-- ------------------ 黑白名单 --------------------- -->
	<div class="box boxr2" id="wireguard_wblist_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="wireguard_wblist_pannel" class="section"></div>
			<script type="text/javascript">
				$('#wireguard_wblist_pannel').forms([
					{ title: '<b>IP/CIDR白名单</b></br></br><font color="#B2B2B2">不需要加速的外网ip/cidr地址，一行一个，例如：</br>2.2.2.2</br>3.3.0.0/16</font>', name: 'wireguard_wan_white_ip', type: 'textarea', value: Base64.decode(dbus.wireguard_wan_white_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名白名单</b></br></br><font color="#B2B2B2">不需要加速的域名，例如：</br>google.com</br>facebook.com</font>', name: 'wireguard_wan_white_domain', type: 'textarea', value: Base64.decode(dbus.wireguard_wan_white_domain)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>IP/CIDR黑名单</b></br></br><font color="#B2B2B2">需要加速的外网ip/cidr地址，一行一个，例如：</br>4.4.4.4</br>5.0.0.0/8</font>', name: 'wireguard_wan_black_ip', type: 'textarea', value: Base64.decode(dbus.wireguard_wan_black_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名黑名单</b></br></br><font color="#B2B2B2">需要加速的域名,例如：</br>baidu.com</br>koolshare.cn</font>', name: 'wireguard_wan_black_domain', type: 'textarea', value: Base64.decode(dbus.wireguard_wan_black_domain)||"", style: 'width: 100%; height:150px;' }
				]);
			</script>
		</div>
	</div>	
	<!-- ------------------ 访问控制 --------------------- -->
	<div class="box boxr3" id="wireguard_acl_tab" style="margin-top: 0px;">
		<div class="content">
			<div class="tabContent">
				<table class="line-table" cellspacing=1 id="wireguard_acl_pannel"></table>
			</div>
			<br><hr>
		</div>
	</div>
	<div id="acl_userreadme" class="box boxr3" style="margin-top: 15px;">
	<div class="heading"><a class="pull-right" data-toggle="tooltip" title="Hide/Show Notes" href="javascript:toggleVisibility('notes');"><span id="sesdivnotesshowhide"><i class="icon-chevron-up"></i></span></a></div>
	<div class="section content" id="sesdivnotes" style="display:">
			<li> 所有模式均支持UDP代理</li>
			<li> MAC暂不可用，请使用IP设置访问控制</li>
	</div>
	</div>
	<!-- ------------------ 附加设置 --------------------- -->
	<div class="box boxr5" id="wireguard_addon_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="wireguard_addon_pannel" class="section"></div>
			<script type="text/javascript">
				$('#wireguard_addon_pannel').forms([
					{ title: 'wireguard 数据操作', suffix: '<button onclick="manipulate_conf(\'wireguard_config.sh\', 2);" class="btn btn-success">清除所有 wireguard 数据</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="manipulate_conf(\'wireguard_config.sh\', 3);" class="btn btn-download">备份所有 wireguard 数据</button>' },
					{ title: 'wireguard 数据恢复', suffix: '<input type="file" id="file" size="50">&nbsp;&nbsp;<button id="upload1" type="button"  onclick="restore_conf();" class="btn btn-danger">上传并恢复 <i class="icon-cloud"></i></button>' }
				]);
				$('#wireguard_version').html(dbus.wireguard_basic_version || "未初始化");
			</script>
		</div>
	</div>
	<div class="box boxr6" id="wireguard_log_tab" style="margin-top: 0px;">
		<div id="wireguard_log_pannel" class="content">
			<div class="section content">
				<script type="text/javascript">
					y = Math.floor(docu.getViewSize().height * 0.45);
					s = 'height:' + ((y > 300) ? y : 300) + 'px;display:block';
					$('#wireguard_log_pannel').append('<textarea class="as-script" name="_wireguard_basic_log" id="_wireguard_basic_log" readonly wrap="off" style="max-width:100%; min-width: 100%; margin: 0; ' + s + '" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>');
				</script>
			</div>
		</div>
	</div>
	<div id="msg_warring" class="alert alert-warning icon" style="display:none;"></div>
	<div id="msg_success" class="alert alert-success icon" style="display:none;"></div>
	<div id="msg_error" class="alert alert-error icon" style="display:none;"></div>
	<button type="button" value="Save" id="save-button" onclick="save()" class="btn btn-primary">提交 <i class="icon-check"></i></button>
	<script type="text/javascript">init_wireguard();</script>
</content>
