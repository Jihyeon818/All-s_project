package bit.naver.mapper;

import bit.naver.entity.StudyGroup;
import bit.naver.entity.StudyList;
import bit.naver.entity.StudyMembers;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface StudyGroupMapper {

    // 스터디 모집 테이블 데이터 삽입
    void insertStudy(StudyGroup studyGroup);

    // Memebers 테이블에 데이터 삽입
    void insertStudyMember(StudyMembers studyMember);

    // studyIdx 최근에 생성된 것 찾기
    Long findStudyIdx(Long userIdx);


    // 내 스터디 리스트
    List<StudyList> getMyStudies(Long userIdx);

    // 스터디 메인 타이틀
    StudyGroup getStudyById(Long studyIdx);

    //  스터디 메인 페이지 유저
    List<StudyMembers> getStudyMembers(Long studyIdx);

    void deleteStudy(Long studyIdx);

    void removeMember(@Param("studyIdx") Long studyIdx, @Param("userIdx") Long userIdx);

    void approveMember(@Param("studyIdx") Long studyIdx, @Param("userIdx") Long userIdx);

    StudyMembers getStudyMember(@Param("studyIdx") Long studyIdx, @Param("userIdx") Long userIdx);

    void updateMemberStatus(@Param("studyIdx") Long studyIdx, @Param("userIdx") Long userIdx, @Param("status") String status);

    int countAllStudies();
    // 추가된 메서드: 승인된 스터디 목록 가져오기
    List<StudyList> getApprovedStudies(Long userIdx);

    // List<StudyList> getAllMyStudies(Long userIdx);
    List<StudyList> getAllMyStudies(@Param("userIdx")Long userIdx, @Param("searchKeyword") String searchKeyword,@Param("searchOption") String searchOption);
//    List<StudyList> getAllMyStudies(Long userIdx);

    void deleteTeamCalendarsByStudyIdx(Long studyIdx);

    void deleteStudyMembersByStudyIdx(Long studyIdx);
//    void approveMember(Long studyIdx, Long userIdx);

    @Select("SELECT study_idx as studyIdx, study_title AS studyTitle, category, latitude, longitude,likes_count AS likesCount, currentParticipants, capacity,distance FROM Studies") // 필요한 정보만 조회
    List<StudyGroup> findAllStudies();

    // 신고된 스터디 목록 조회
    List<StudyGroup> getReportedStudies(@Param("offset") int offset, @Param("limit") int limit);

    // 신고된 스터디 개수 조회
    int countReportedStudies();

    boolean isMember(@Param("studyIdx") Long studyIdx, @Param("userIdx") Long userIdx);


    @Update("UPDATE Studies SET description_title = #{descriptionTitle}, description = #{description}, category = #{category}, age = #{age}, gender = #{gender}, study_online = #{studyOnline} WHERE study_idx = #{studyIdx}")
    void updateStudy(StudyGroup studyGroup);

    void updateStudyGroup(StudyGroup studyGroup);


    void updateStudyGroupInfo(StudyGroup studyGroup);

    // 멤버 수 증가
    @Update("UPDATE Studies SET currentParticipants = currentParticipants + 1 WHERE study_idx = #{studyIdx}")
    void incrementCurrentParticipants(@Param("studyIdx") Long studyIdx);

    // 멤버 수 감소
    @Update("UPDATE Studies SET currentParticipants = currentParticipants - 1 WHERE study_idx = #{studyIdx}")
    void decrementCurrentParticipants(@Param("studyIdx") Long studyIdx);

    Long getStudyLeaderIdx(Long studyIdx);

    // 스터디 그룹의 회원들을 공부 시간 기준으로 정렬하여 조회
    @Select("SELECT u.user_idx as userIdx, u.name as userName, u.total_study_time as totalStudyTime " +
            "FROM StudyMembers sm " +
            "JOIN Users u ON sm.user_idx = u.user_idx " +
            "WHERE sm.study_idx = #{studyIdx} AND sm.status = 'ACCEPTED' " +
            "ORDER BY u.total_study_time DESC")
    List<Map<String, Object>> getStudyMembersByStudyTime(@Param("studyIdx") Long studyIdx);

    List<StudyGroup> findNearestStudies(@Param("userLatitude") double userLatitude, @Param("userLongitude") double userLongitude, @Param("limit") int limit);
    List<StudyGroup> getAllStudies(@Param("userLatitude") double userLatitude, @Param("userLongitude") double userLongitude);
    List<StudyGroup> getIStudies(Long userIdx); // 사용자가 참여 중인 스터디 목록 조회 메서드 추가
    List<StudyGroup> getJoinedStudies(@Param("userLatitude") Double userLatitude, @Param("userLongitude") Double userLongitude, @Param("userIdx") Long userIdx);

    // 현재 모집 인원과 정원
    @Select("SELECT currentParticipants, capacity FROM Studies WHERE study_idx = #{studyIdx}")
    Map<String, Integer> getCurrentParticipantsAndCapacity(Long studyIdx);
}