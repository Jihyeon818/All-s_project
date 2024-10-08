package bit.naver.controller;

import bit.naver.entity.NotificationEntity;
import bit.naver.entity.StudyGroup;
import bit.naver.entity.Users;
import bit.naver.listener.MyHttpSessionEventPublisher;
import bit.naver.mapper.NotificationMapper;
import bit.naver.mapper.StudyGroupMapper;
import bit.naver.mapper.StudyRecruitMapper;
import bit.naver.mapper.UsersMapper;
import bit.naver.security.UsersUser;
import lombok.extern.log4j.Log4j;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.security.Principal;
import java.util.List;

@Slf4j
@Controller
public class MainController {

    @Autowired
    private UsersMapper usersMapper;

    @Autowired
    private StudyRecruitMapper studyMapper;

    @Value("${kakao.map.api.key}") // application.properties에서 API 키 값 가져오기
    private String kakaoMapApiKey;

    @Value("${google.maps.api.key}")
    private String googleMapsApiKey;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StudyGroupMapper studyGroupMapper;



    @RequestMapping("/main")
    public String mainScreen(Model model ,HttpSession session) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UsersUser) {
            UsersUser usersUser = (UsersUser) authentication.getPrincipal();
            Users user = usersUser.getUsers();
            model.addAttribute("userVo", user); // Users 객체를 모델에 추가
            session.setAttribute("userVo", user);
            String username = user.getName();
            Users users = usersMapper.findByUsername(username);
            Long userIdx = Long.valueOf(users != null ? users.getUserIdx() : 59);
            List<StudyGroup> study_18 = studyMapper.getAllStudy_9(userIdx);
            model.addAttribute("study_18", study_18);

            List<StudyGroup> myStudies = studyGroupMapper.getJoinedStudies(user.getLatitude(), user.getLongitude(), userIdx);
            session.setAttribute("myStudies", myStudies);
            model.addAttribute("myStudies", myStudies); // myStudies를 model에 추가

            session.setAttribute("weatherLatitude", user.getLatitude());
            session.setAttribute("weatherLongitude", user.getLongitude());
            // 참여 중인 스터디가 있는 경우 첫 번째 스터디 정보를 세션에 추가
            if (!myStudies.isEmpty()) {
                StudyGroup currentStudy = myStudies.get(0);
                session.setAttribute("study", currentStudy);
                model.addAttribute("study", currentStudy); // study 객체 추가

            }
        }
        Users userVo = (Users) session.getAttribute("userVo");
        if (userVo != null) {
            log.info("메인 페이지 접속 (username: {})", userVo.getUsername()); // 로그 추가
            model.addAttribute("userVo", userVo);
            session.setAttribute("userVo", userVo);
            String username = userVo.getName();
            Users users = usersMapper.findByUsername(username);
            Long userIdx = Long.valueOf(users != null ? users.getUserIdx() : 59);
            List<StudyGroup> study_18 = studyMapper.getAllStudy_9(userIdx);
            model.addAttribute("study_18", study_18);
            session.setAttribute("weatherLatitude", userVo.getLatitude());
            session.setAttribute("weatherLongitude", userVo.getLongitude());
            // 사용자가 참여 중인 스터디 목록 조회
            List<StudyGroup> myStudies = studyGroupMapper.getJoinedStudies(userVo.getLatitude(), userVo.getLongitude(), userIdx);
            session.setAttribute("myStudies", myStudies);
            model.addAttribute("myStudies", myStudies); // myStudies를 model에 추가

            // 참여 중인 스터디가 있는 경우 첫 번째 스터디 정보를 세션에 추가
            if (!myStudies.isEmpty()) {
                StudyGroup currentStudy = myStudies.get(0);
                session.setAttribute("study", currentStudy);
                model.addAttribute("study", currentStudy); // study 객체 추가

            }
        } else {
            log.warn("메인 페이지 접근 시도 (로그인되지 않은 사용자)"); // 로그 추가

            List<StudyGroup> study_18 = studyMapper.getAllStudy_9(0);
            model.addAttribute("study_18", study_18);
        }
        model.addAttribute("kakaoMapApiKey", kakaoMapApiKey); // API 키를 모델에 추가



        return "/main";
    }


    @RequestMapping("/include/header")
    public String header (Model model,HttpSession session, Principal principal) {
        if(session.getAttribute("userVo") != null) {
            Users userVo = (Users) session.getAttribute("userVo");
            System.out.println(userVo);
            session.setAttribute("userVo", userVo);
            session.setAttribute("weatherLatitude", userVo.getLatitude());
            session.setAttribute("weatherLongitude", userVo.getLongitude());
        }else {
            String username = principal.getName();
            Users user = usersMapper.findByUsername(username);
            model.addAttribute("user", user);
            session.setAttribute("userVo", user);
            session.setAttribute("weatherLatitude", user.getLatitude());
            session.setAttribute("weatherLongitude", user.getLongitude());
            Long userIdx = user.getUserIdx();

        }
        model.addAttribute("googleMapsApiKey", googleMapsApiKey);
        return "/include/header";
    }

    @RequestMapping("/include/footer")
    public String footer(Model model,HttpSession session, Principal principal) {
        String username = principal.getName();
        Users user = usersMapper.findByUsername(username);
        model.addAttribute("user", user);
        session.setAttribute("userVo", user);
        return "/include/footer";
    }
    @RequestMapping("/include/navbar/")
    public String navbar(Model model,HttpSession session, Principal principal) {
        String username = principal.getName();
        Users user = usersMapper.findByUsername(username);
        model.addAttribute("user", user);
        session.setAttribute("userVo", user);
        return "/include/navbar";
    }
    @RequestMapping("/include/timer")
    public String timer(Model model,HttpSession session, Principal principal) {
        String username = principal.getName();
        Users user = usersMapper.findByUsername(username);
        model.addAttribute("user", user);
        session.setAttribute("userVo", user);
        return "/include/timer";
    }
    
}

