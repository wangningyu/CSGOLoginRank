#if defined _data_manager_included
  #endinput
#endif
#define _data_manager_included

// 积分类别
enum StatsType
{
	STATS_KILL = 'A',
	STATS_SHOT,
	STATS_HEADSHOT,
	STATS_HIT,
	STATS_DAMAGE,

	STATS_DEATH,
	STATS_FIRSTKILL,
	STATS_FIRSTDEATH,
	STATS_BOMB_DEFUSION,
	STATS_BOMB_PLANTING,
	STATS_TIME_ONLINE,
	STATS_ASSIST,
}

enum PStatsType
{
	PSTATS_RANK = 0,
	PSTATS_SCORE,
	PSTATS_KILL,
	PSTATS_SHOT,
	PSTATS_HEADSHOT,
	PSTATS_HIT,
	PSTATS_DAMAGE,

	PSTATS_DEATH,
	PSTATS_FIRSTKILL,
	PSTATS_FIRSTDEATH,
	PSTATS_BOMB_DEFUSION,
	PSTATS_BOMB_PLANTING,
	PSTATS_TIME_ONLINE,
	PSTATS_ASSIST,
}

// weapon_id - CSW_id for default weapons and SKILL_id for skill/spells , 0 for player stats(STATS_DEATH,STATS_FIRSTKILL...)
// increment - MUST be a positive number
native dm_push_stats(category, weapon_id, uid, increment)

// 试图获取个人统计信息.
// 若成功,则触发foward receive_stats()
native dm_get_stats(id, uid)

forward receive_stats(id, data[13])