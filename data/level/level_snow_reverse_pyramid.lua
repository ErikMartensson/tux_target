Name = "Snow Reverse Pyramid"
Author = "Skeet"
ServerLua = "data/lua/level_default_server.lua"
ReleaseLevel = 5

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
	CVector(0, 3, 10),
	CVector(0, 3, 10)
}

StartPoints =
{
	CVector(-0.5, 1.6, 9.38),
	CVector(-0.45, 1.6, 9.38),
	CVector(-0.4, 1.6, 9.38),
	CVector(-0.35, 1.6, 9.38),
	CVector(-0.3, 1.6, 9.38),
	CVector(-0.25, 1.6, 9.38),
	CVector(-0.2, 1.6, 9.38),
	CVector(-0.15, 1.6, 9.38),
	CVector(-0.1, 1.6, 9.38),
	CVector(-0.05, 1.6, 9.38),
	CVector(0.0, 1.6, 9.38),
	CVector(0.05, 1.6, 9.38),
	CVector(0.1, 1.6, 9.38),
	CVector(0.15, 1.6, 9.38),
	CVector(0.2, 1.6, 9.38),
	CVector(0.25, 1.6, 9.38)
}

Modules =
{
	{ Position = CVector(0, 0, 5), Scale = CVector(1, 1, 1), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_ramp", Shape="snow_ramp", Friction = 0, Bounce = 0, Accel = 0.0001 },
	{ Position = CVector(0, -15, 3.2), Scale = CVector(14, 14, 0.5), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 50, Friction = 10, Color = CRGBA(100, 255, 100, 255) },
	{ Position = CVector(0, -15, 3.1), Scale = CVector(7, 7, 0.5), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 100, Friction = 15, Color = CRGBA(100, 100, 255, 255) },
	{ Position = CVector(0, -15, 3.0), Scale = CVector(3, 3, 0.5), Rotation = CAngleAxis(1,0,0,0), Lua = "snow_box", Shape="snow_box", Score = 300, Friction = 40, Color = CRGBA(255, 100, 100, 255) }
}

Particles =
{
}

ExternalCameras =
{
	{ Position = CVector(-0.074286, -15.216643, 3.229653), Rotation = CAngleAxis(-0.112392, 0.012555, -0.110309, 0.987442) },
}
