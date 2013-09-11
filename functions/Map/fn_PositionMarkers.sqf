/**
 * Enemy Unit Map Marker Update Script
 * Displays dots on the players map with the most recently known position of any hostile units.
 *
 * @signature [enabled, interval, condition, style]
 * @param enabled Whether or not to enable the updated map markers globally (default: true)
 * @param interval The amount of time to wait between map updates (default: 10)
 * @param condition Condition specifying which units should be shown on the map (default: { side _x != side player })
 * @param style The marker icon used for units (default: "mil_dot")
 */

private ["_enabled", "_interval", "_condition", "_style", "_units", "_markerName", "_newUnits"];

_enabled = [_this, 0, true, [true]] call BIS_fnc_param;
_interval = [_this, 1, 10, [1]] call BIS_fnc_param;
_condition = [_this, 2, { side _x != side player }, [{true}]] call BIS_fnc_param;
_style = [_this, 3, "mil_dot", [""]] call BIS_fnc_param;

Sierra_position_markers = _enabled;
publicVariable "Sierra_position_markers";

Sierra_position_markers_interval = _interval;
publicVariable "Sierra_position_markers_interval";

if(!_enabled) exitWith {false};

// Make sure that this global variable is defined
if(isServer && (isNil "Sierra_position_markers_active_server")) then { Sierra_position_markers_active_server = false; };
if((isNil "Sierra_position_markers_active")) then { Sierra_position_markers_active = false; };

// Populate a list of all units to be affected by these markers
_units = [];
{
	if(alive _x && (call _condition)) then {
		_units set [count _units, _x];
	};
} forEach allUnits;

// Place them into a global variable which is only updated by the server
Sierra_position_markers_units = _units;
publicVariable "Sierra_position_markers_units";

Sierra_position_markers_dead = [];
publicVariable "Sierra_position_markers_dead";

// Start the server update script
if(isServer && !Sierra_position_markers_active_server) then {
	[] spawn {
		Sierra_position_markers_active_server = true;

		while {Sierra_position_markers} do {
			// Update units list by removing dead units
			sleep Sierra_position_markers_interval / 2;

			if({ !alive _x } count Sierra_position_markers_units > 0) then {
				_newUnits = [];
				{
					if(alive _x) then {
						_newUnits set [count _newUnits, _x];
					} else {
						Sierra_position_markers_dead set [count Sierra_position_markers_dead, _x];
					};
				} forEach Sierra_position_markers_units;

				Sierra_position_markers_units = _newUnits;
				publicVariable "Sierra_position_markers_units";
				publicVariable "Sierra_position_markers_dead";
			};
		};

		Sierra_position_markers_active_server = false;
	};
};

if(!Sierra_position_markers_active) then {
	[_style] spawn {
		_style = _this select 0;

		Sierra_position_markers_active = true;

		while { Sierra_position_markers } do {
			{
				_marker = _x getVariable "Sierra_position_marker";

				if((isNil {_marker})) then {				
					_markerName = str(format ["Sierra_position_marker_%1", name _x]);

					_marker = createMarkerLocal [_markerName, position _x];
					_marker setMarkerSizeLocal [0.6,0.6];
					_marker setMarkerShapeLocal "ICON";
					_marker setMarkerTypeLocal _style;

					if(side _x == side player) then {
						_marker setMarkerColorLocal "ColorBlue";
					} else {
						_marker setMarkerColorLocal "ColorRed";
					};
					_x setVariable ["Sierra_position_marker", _marker];
				};

				_marker setMarkerPosLocal position _x;
				_marker setMarkerDirLocal direction _x;
			} forEach Sierra_position_markers_units;

			// Clean up deak markers
			{
				_marker = _x getVariable "Sierra_position_marker";

				if(!(isNil {_marker})) then {	
					deleteMarkerLocal _marker;
					_x setVariable ["Sierra_position_marker", nil];
				};
			} forEach Sierra_position_markers_dead;

			sleep Sierra_position_markers_interval;
		};

		// Clean up all remaining markers
		{
			_marker = _x getVariable "Sierra_position_marker";
			if(!(isNil {_marker})) then { 
				deleteMarkerLocal _marker;
				_x setVariable ["Sierra_position_marker", nil];
			};
		} forEach Sierra_position_markers_units;

		// Clean up deak markers
		{
			_marker = _x getVariable "Sierra_position_marker";
			if(!(isNil {_marker})) then {	
				deleteMarkerLocal _marker;
				_x setVariable ["Sierra_position_marker", nil];
			};
		} forEach Sierra_position_markers_dead;

		Sierra_position_markers_active = false;
	};
};

true