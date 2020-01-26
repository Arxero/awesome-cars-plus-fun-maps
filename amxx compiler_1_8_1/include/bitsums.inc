#define bitsum_add(%1,%2) 		%1 |= (1 << ((%2 - 1) & 31))
#define bitsum_del(%1,%2) 		%1 &= ~(1 << ((%2 - 1) & 31))
#define bitsum_get(%1,%2) 		(%1 & (1 << ((%2 - 1) & 31)))

#define add_bitsum(%1,%2) 		bitsum_add(%1,%2)
#define del_bitsum(%1,%2) 		bitsum_del(%1,%2)
#define get_bitsum(%1,%2) 		bitsum_get(%1,%2)

stock iIDToBit(const iID)
{
	return (1 << ((iID - 1) & 31));
}