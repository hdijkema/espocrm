/************************************************************************
 * vi: set sw=4 ts=4: 
 *
 * This file is part of EspoCRM.
 *
 * EspoCRM - Open Source CRM application.
 * Copyright (C) 2014-2020 Yuri Kuznetsov, Taras Machyshyn, Oleksiy Avramenko
 * Website: https://www.espocrm.com
 *
 * EspoCRM is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EspoCRM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with EspoCRM. If not, see http://www.gnu.org/licenses/.
 *
 * The interactive user interfaces in modified source and object code versions
 * of this program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU General Public License version 3.
 *
 * In accordance with Section 7(b) of the GNU General Public License version 3,
 * these Appropriate Legal Notices must retain the display of the "EspoCRM" word.
 ************************************************************************/

define('signals', [ ], function () {

	var flagged_ids = [];

	if (typeof window.hd_signals === 'undefined') {
		window.hd_signals = [];
		window.setInterval(
				function() {
					window.hd_signals.forEach(function(f, idx) { f(100); });
				},
				100
			);
		window.setInterval(
				function() {
            		$.ajax({
                		url: '/api/v1/WebSignals/FlaggedSignals.php',
                		dataType: 'json',
                		local: true,
                		success: function(data) {
							data.flagged.forEach(function(id, idx) {
								flagged_ids.push(id);
							});
                		}
            		});
				},
				2000
			);
    }

	var checkId = function(id, callback) {
		console.log("checkId: " + id);
		console.log(flagged_ids);
		flagged_ids = flagged_ids.filter(function(flagged_id, idx, arr) {
			if (id == flagged_ids) { callback();return false; } else { return true; }
		});
	};

    var Signals = {
		registerSignal: function (id, callback, seconds = 1) {
							$.ajax({
                				url: '/api/v1/WebSignals/RegisterSignal.php?id=' + id,
                				dataType: 'json',
                				local: true,
                				success: function(data) {
									if (seconds < 1) { seconds = 1; }
									var _mseconds = seconds * 1000;
									var _ticks = 0;
									window.hd_signals.push(
										function(ms) {
											_ticks += ms;
											if (_ticks >= _mseconds) {
												_ticks = 0;
												checkId(id, callback);
											}
										}
									);
								}
							});
						}

	};

	return Signals;
});

