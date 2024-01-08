extends Node

func point_in_ellipse(oPos: Vector2, ePos: Vector2, rads) -> bool:
	return ((oPos - ePos) / rads).length_squared() <= 1;

func distance_to_ellipse(oPos: Vector2, ePos: Vector2, rads) -> float:
	var dPos  = oPos - ePos;

	if dPos.x == 0:
		if dPos.y <= 0:
			return abs(rads.y + dPos.y);
		else:
			return abs(rads.y - dPos.y);

	var dPos2 = dPos * dPos;

	var rads2 = rads * rads;

	var Tx1 = sqrt((rads2.x * rads2.y * dPos2.x) / Vector2(rads2.y, rads2.x).dot(dPos2));
	var Tx2 = -Tx1;

	var m	= dPos.y / dPos.x;
	var Ty1	= m * Tx1;
	var Ty2	= m * Tx2;

	var dist1 = (Vector2(Tx1, Ty1) - dPos).length_squared();
	var dist2 = (Vector2(Tx2, Ty2) - dPos).length_squared();

	return sqrt(minf(dist1, dist2));

func trangent_points_on_ellipse(oPos: Vector2, ePos: Vector2, rads : Vector2) -> Array[Vector2]:
	var dPos  = oPos - ePos;
	var dPos2 = dPos * dPos;

	var rads2  = rads * rads;

	var tanVec1 = Vector2.ZERO;
	var tanVec2 = Vector2.ZERO;
	var dist1: int;
	var dist2: int;
	if point_in_ellipse(oPos, ePos, rads):
		if dPos.x == 0:
			tanVec1 = Vector2(0, rads.y);
			tanVec2 = Vector2(0, -rads.y);
		else:
			tanVec1.x = -sqrt((dPos2.x * dPos2.y * rads2.x) / dPos2.dot(rads2));
			tanVec2.x = -tanVec1.x;

			var m	  = dPos.y / dPos.x;
			tanVec1.y = m * tanVec1.x;
			tanVec2.y = m * tanVec2.x;
	else:
		var A = (rads2.x * dPos2.y) + (rads2.y * dPos2.x)

		if abs(dPos.y) <= abs(dPos.x):
			var B = -2 * rads2.x * rads2.y * dPos.y;
			var C = (rads2.y * rads2.y) * (rads2.x - dPos2.x);

			var discriminant = sqrt(B*B - 4*A*C);
			var xOffset	=  (rads2.x / dPos.x);
			var xMul	= -(rads2.x * dPos.y) / (rads2.y * dPos.x);

			tanVec1.y = ((-B - discriminant) / (2 * A));
			tanVec2.y = ((-B + discriminant) / (2 * A));

			tanVec1.x = xMul * tanVec1.y + xOffset;
			tanVec2.x = xMul * tanVec2.y + xOffset;
		else:
			var B = -2 * rads2.x * rads2.y * dPos.x;
			var C = (rads2.x * rads2.x) * (rads2.y - dPos2.y);

			var discriminant = sqrt(B*B - 4*A*C);
			var yOffset	=  (rads2.y / dPos.y);
			var yMul	= -(rads2.y * dPos.x) / (rads2.x * dPos.y);

			tanVec1.x = ((-B - discriminant) / (2 * A));
			tanVec2.x = ((-B + discriminant) / (2 * A));

			tanVec1.y = yMul * tanVec1.x + yOffset;
			tanVec2.y = yMul * tanVec2.x + yOffset;
	dist1 = abs(tanVec1.x - dPos.x) + abs(tanVec1.y - dPos.y);
	dist2 = abs(tanVec2.x - dPos.x) + abs(tanVec2.y - dPos.y);

	if dist1 <= dist2:
		return [tanVec1 + ePos, tanVec2 + ePos];
	else:
		return [tanVec2 + ePos, tanVec1 + ePos];
