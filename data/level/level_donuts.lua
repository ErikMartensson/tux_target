Name = "Give me the donuts"
Author = "erendis"
ServerLua = "data/lua/level_donuts_server.lua"
ReleaseLevel = 2

skyShapeFileName = "sky.shape";
sunAmbientColor = CRGBA(82, 100, 133, 255);
sunDiffuseColor = CRGBA(255, 255, 255, 255);
sunSpecularColor = CRGBA(255, 255, 255, 255);
sunDirection = CVector(-1,0,-1);

clearColor = CRGBA(30, 45, 90, 0);

fogDistMin = 0;
fogDistMax = 150;
fogColor = clearColor;

Cameras =
{
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10),
	CVector(0, 3, 10)

}

StartPoints =
{
	CVector(-0.25109, 8.56534, 12.68978),
	CVector(-0.411029, 8.55867, 12.68978),
	CVector(-0.570633, 8.55203, 12.68978),
	CVector(-0.0733468, 8.5695, 12.68978),
	CVector(-0.225997, 8.56282, 12.68978),
	CVector(-0.394393, 8.55616, 12.68978),
	CVector(-0.554403, 8.554953, 12.68978),
	CVector(-0.178982, 8.5806, 12.68978),
	CVector(-0.331207, 8.58197, 12.68978)
}

Modules ={
	{ Position = CVector(-15,-10.0,2.0), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(1.0,0.0,0.0,0.0), Lua="snow_island3", Shape="snow_island3", Friction = 0 },
	{ Position = CVector(15,-12.0,2.0), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(0.0,0.0,1.0,1.58), Lua="snow_island3", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(8,-6.0,2.0), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(0.0,0.0,1.0,2.58), Lua="snow_island3", Shape="snow_island3", Friction = 0 },

	{ Position = CVector(-10,-20.0,2.0), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(0.0,0.0,1.0,-1.58), Lua="snow_island3", Shape="snow_island2", Friction = 0 },
	{ Position = CVector(10,-20.0,2.0), Scale = CVector(1.000000, 1.000000, 1.000000), Rotation = CAngleAxis(0.0,0.0,1.0,-2.58), Lua="snow_island3", Shape="snow_island3", Friction = 0 },

	{ Position = CVector(1.5,-6,6), Scale = CVector(200.0, 100.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(1.5,-6,6), Scale = CVector(400.0, 200.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(1.5,-6,6), Scale = CVector(800.0, 400.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.1,-8,5), Scale = CVector(200.0, 100.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.1,-8,5), Scale = CVector(400.0, 200.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-10,4.5), Scale = CVector(30.0, 15.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-10,4.5), Scale = CVector(125.0, 70.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-10,4.5), Scale = CVector(250.0, 150.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-12,3.9), Scale = CVector(250.0, 100.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-12,3.9), Scale = CVector(500.0, 200.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.5,-12,3.9), Scale = CVector(1000.0, 400.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(0.5,-11,4.5), Scale = CVector(100.0, 800.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(0.5,-11,4.5), Scale = CVector(200.0, 1600.000000, 20.000000), Rotation = CAngleAxis(10.000000,0.000000,0.000000,1.570000), Lua="snow_neutral", Shape="snow_torus", Friction = 0 },
	{ Position = CVector(-0.1,-16.5,1.2), Scale = CVector(0.900000, 0.900000, 0.100000), Rotation = CAngleAxis(1.000000,0.000000,0.000000,0.000000), Lua="snow_target_100", Shape="snow_bowl", Score = 100, Friction = 25 },
	{ Position = CVector(-0.1,-14.872,3), Scale = CVector(4.00000, 1.000000, 1.00000), Rotation = CAngleAxis(0.000000,-2.000000,5.000000,1.580000), Lua="race_lane", Shape="race_jump", Friction = 0 },
	{ Position = CVector(0,-16.5,2.5), Scale = CVector(50.0000, 80.00000, 1.2000), Rotation = CAngleAxis(10.000000,0.0 ,0.0 ,1.5700), Lua="box_sol", Shape="box_sol", Friction = 0 },
	{ Position = CVector(-0.1,-16.5,1.5), Scale = CVector(5.000000, 5.000000, 2.100000), Rotation = CAngleAxis(1.000000,0.000000,0.000000,0.000000), Lua="snow_neutral", Shape="snow_funnel", Friction = 0 },
	{ Position = CVector(-0.1,7,8), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua="snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },


}


Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(0.260632, -16.652920, 1.270847), Rotation = CAngleAxis(0.028885, 0.012964, 0.409266, 0.911866) },
}