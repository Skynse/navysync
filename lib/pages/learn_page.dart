import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<LearnSection> _sections = [
    LearnSection(
      title: 'Learn Page',
      icon: Icons.book,
      difficulty: 'Info',
      content: '''
Welcome to the Learn page!

📚 About This Learning Material

Welcome to the Learn module! This comprehensive guide contains essential naval knowledge and curriculum information to support your NJROTC education and training.

📖 Source Materials

The information presented in this learning module is compiled from the following official NJROTC publications:

• Cadet Reference Manual (CRM) 4th Edition, 2024
• Cadet Field Manual (CFM) 12th Edition, April 2024
• Cadet Drill Manual (CDM) 1st Edition, May 2024
• Naval Science 1, 3rd Edition
• Naval Science 2, 4th Edition  
• Naval Science 3, 3rd Edition
• Naval Science 4, 1st Edition

🎯 Learning Objectives

This module is designed to help you:
• Master fundamental naval knowledge and traditions
• Understand military organization and chain of command
• Prepare for Regular Personnel Inspections
• Study for Advancement Exams

⚓ Study Tips

• Review each section thoroughly
• Practice reciting the General Orders
• Memorize the Chain of Command

Ready to begin your journey? Navigate through the sections using the Previous/Next buttons below.

Fair winds and following seas! ⚓
      ''',
    ),
    LearnSection(
      title: 'General Orders of the Sentry',
      icon: Icons.shield,
      difficulty: 'Basic Knowledge',
      content: '''
🎖️ THE ELEVEN GENERALS OF THE SENTRY

These 11 General Orders form the bedrock of military watch standing and are fundamental to every sailor's duty:

1. To take charge of this post and all government property in view.

2. To walk my post in a military manner, keeping always on the alert, and observing everything that takes place within sight or hearing.

3. To report all violations of orders I am instructed to enforce.

4. To repeat all calls from posts more distant from the guardhouse than my own.

5. To quit my post only when properly relieved.

6. To receive, obey, and pass on to the sentry who relieves me all orders from the Commanding Officer, Command Duty Officer, Officer of the Deck, and Officers and Petty Officers of the watch only.

7. To talk to no one except in the line of duty.

8. To give the alarm in case of fire or disorder.

9. To call the Officer of the Deck in any case not covered by instructions.

10. To salute all officers and all colors and standards not cased.

11. To be especially watchful at night, and during the time for challenging, challenge all persons on or near my post, and to allow no one to pass without proper authority.

You will need to know this for Personnel Inspection and the c/SA Advancement Exam!
      ''',
    ),
    LearnSection(
      title: 'Chain of Command',
      icon: Icons.military_tech,
      difficulty: 'Basic Knowledge',
      content: '''
⚔️ CHAIN OF COMMAND

Understanding the chain of command is fundamental to naval organization and discipline. Here is the complete hierarchy from the highest level to our unit:

1. Commander in Chief/President
   President Donald J. Trump

2. Vice President
   Vice President James D. Vance

3. Chairman of the Joint Chiefs of Staff
   GEN Dan Caine

4. Secretary of State
   The Honorable Marco Rubio

5. Secretary of Defense
   The Honorable Pete Hegseth

6. Secretary of the Navy
   The Honorable John Phelan

7. Chief of Naval Operations (CNO)
   ADM Daryl Caudle

7A. Master Chief Petty Officer of the Navy (MCPON)
   MCPON (SW/AW) James Honea

8. Commandant of the Marine Corps
   GEN Eric M. Smith

8A. Sergeant Major of the Marine Corps (SMOMC)
   SMMC Carlos A. Ruiz

9. Naval Education and Training Command (NETC)
   RADM Gregory C. Huffman

10. Naval Service Training Command (NSTC)
   RADM Matthew T. Pottenburgh

11. NJROTC Program Director
   Mr. Bruce Nolan

12. Area Manager Area 21
   CDR Thomas Garcia

13. Senior Naval Science Instructor
   CDR William M. Lauper, USN (Ret.)

14. Naval Science Instructors
   NS3 - LT Roger Fronek, USN (Ret.)
   NS2 - PNCM (SW/AW) Eduardo David, USN (Ret.)
   NS1 - FSGT Warren Barnes, USMC (Ret.)

You will need to know this for Personnel Inspection and the c/SA Advancement Exam!
      ''',
    ),
    LearnSection(
      title: 'Grooming Standards',
      icon: Icons.face,
      difficulty: 'Beginner',
      content: '''
📋 PERSONAL APPEARANCE AND GROOMING
(Source: Cadet Field Manual, Pages 5-8)

👨 Men's Grooming Standards

Hair: Keep hair neat, clean and well groomed (combed or brushed). Hairstyles and haircuts will present a balanced professional appearance. Hairstyles worn in uniform will not interfere with the wearing of all uniform covers or the proper wearing of safety equipment. Hair coloring is left to the discretion of the instructors. Note: Ethnic hairstyles are permitted, provided they are groomed to fit within the guidelines stated here. Bizarre hairstyles and faddish hair are not authorized.

Sideburns: Neatly trimmed and tailored as described here. Shall not extend below a point level with the middle of the ear, as indicated by line A and shall be of even width (not tapered or flared). Shall end with a clean-shaven horizontal line.

Mustaches: Neat and closely trimmed. No portion shall extend below the upper lip line. Shall not be below the horizontal line extending across the corners of the mouth. Shall not be more than ¼ inch beyond a vertical line drawn upward from the corners of the mouth. No other facial hair is permitted.

Fingernails: Will not extend past the fingertips.

Earrings/Studs: Not authorized in the ear, nose, eyebrows, tongue, lips, or other areas of the face or body visible to the naval science instructor.

Necklaces: Authorized, but shall not be visible.

Rings: One per hand is authorized.

Wristwatch/Bracelet: One of each is authorized but no ankle bracelets.

Sunglasses: A conservative pair is permitted when authorized by the naval science instructor. Sunglasses are never authorized in military formations. Retainer straps are not authorized.

👩 Women's Grooming Standards

Hair: Hairstyles will not detract from a professional military appearance in uniform. Hairstyles and haircuts will present a balanced professional appearance. Appropriateness of a hairstyle will be evaluated by its appearance when headgear is worn. All headgear will fit snugly and comfortably around the largest part of the head without distortion or excessive gaps. Hairstyles will not interfere with the proper wearing of headgear, protective masks or equipment. All buns and ponytails will be positioned on the back of the head to ensure the proper wearing of all headgear.

Hair Length: Hair length, when in uniform, may touch, but not fall below a horizontal line level with the lower edge of the back of the collar. Long hair, including braids, will be neatly fastened, pinned, or secured to the head. When bangs are worn, they will not extend below the eyebrows. Hair length will be sufficient to prevent the scalp from being readily visible (with the exception of documented medical conditions).

Hair Bulk: Hair bulk (minus the bun) as measured from the scalp will not exceed 2 inches. The bulk of the bun will not exceed 3 inches when measured from the scalp and the diameter of the bun will not exceed or extend beyond the width of the back of the head. Loose ends must be tucked in and secured.

Hair Color: Hair color will be left to the discretion of the instructors.

Ponytails: A ponytail is a hairstyle in which the hair on the head is pulled away from the face, gathered and secured at the back of the head with an approved accessory. Hair extending beyond the securing accessory may be braided or allowed to extend naturally. The wear of a single braid, French braid, or a single ponytail in Service, Working, and PT uniforms is authorized. Ponytail hairstyles will not interfere with the proper wearing of military headwear and equipment nor extend downward more than three inches below the lower edge of the collar while sitting, standing or walking. Additionally, ponytails will not extend outward more than three inches behind the head as measured from the securing accessory, nor shall the width exceed the width of the back of the head or be visible from the front.

Hair Accessories: When hair accessories are worn, they must be consistent with the hair color. A maximum of two small barrettes, similar to hair color, may be used to secure the hair to the head. Bun accessories (used to form the bun), are authorized if completely concealed. Additional hairpins, bobby pins, small rubber bands, or small thin fabric elastic bands may be used to hold hair in place, if necessary.

Hair Ornaments: Must be consistent with the hair color. A maximum of two small barrettes, similar to hair color, may be used to secure the hair to the head. Bun accessories (used to form the bun), are authorized if completely concealed. Headbands, "scrunchies," combs, claws, and butterfly clips are examples of accessories that are not authorized. Conspicuous rubber bands, combs, and pins are not authorized.

Cosmetics: Applied in good taste and colors that blend with natural skin tone. Exaggerated or faddish cosmetics are inappropriate. Lipstick should be conservative.

Fingernails: Fingernails shall not exceed ¼ inch measured from the fingertip. They shall be kept clean. Nail polish may be worn, but colors shall be conservative and complement the skin tone.

Earrings/Studs: One per ear, centered on the earlobe. Must be a small gold or silver ball (post or stud). Studs are not authorized in the nose, eyebrows, tongue, lips, or other areas of the face or body visible to the naval science instructor.

Necklaces: Authorized but shall not be visible.

Rings: One per hand is authorized, plus the engagement ring or the wedding ring.

Wristwatch/Bracelet: One of each is authorized but no ankle bracelets.

Sunglasses: A conservative pair is permitted when authorized by the naval science instructor. Sunglasses are never authorized in military formations. Retainer straps are not authorized.

📝 NOTE: Personal appearance such as the wearing of lip rings, tongue and nose studs, belly rings, and other types of bizarre body jewelry, for both males and females when out of uniform, will be determined by the local school or NJROTC student dress codes.

You will need to know this for the Annual Military Inspection and the c/SN Advancement Exam!
      ''',
    ),
    LearnSection(
      title: 'Drill Terminology',
      icon: Icons.arrow_forward,
      difficulty: 'Beginner',
      content: '''
📐 DRILL TERMINOLOGY
(Source: Cadet Drill Manual, Pages 2-7, 10)

🎯 Essential Drill Terms

Alignment: The dressing of several elements on a straight line.

Cadence: A rhythmic rate of march at a uniform step.

Column: A formation in which elements are placed one behind the other. A section or platoon is in column when members of each squad are one behind the other with the squads abreast of each other.

Depth: The space from head to rear of an element or a formation. (See Figure 1-1a.) The depth of an individual is considered to be 12 inches.

Distance: The space between elements in the direction of depth. Between individuals, the space between your chest and the person to your front. Between cadets in formation, the space from the front of the rear unit to the rear of the unit in front. Platoon commanders, guides, and others whose positions in a formation are 40 inches from a rank are, themselves, considered a rank. Otherwise, commanders and those with them are not considered in measuring distance between units. The color guard is not considered in measuring distance between subdivisions of the unit with which it is posted. In cadet formations, the distance between ranks is 40 inches.

Double Time: Cadence at 180 steps (36 inches in length) per minute.

File: A single column of cadets one behind the other.

Front: The space occupied by an element or a formation, measured from one flank to the other. The front of an individual is considered to be 22 inches.

Inflection: THe rise and fall in pitch with plenty of snap.

Pace: The length of a full step in Quick Time, 30 inches.

Quick Time: Cadence at 112 to 120 steps (12, 15, or 30 inches in length) per minute. It is the normal cadence for drills and ceremonies.

Rank: A line of cadets placed side by side.

Slow Time: Cadence at 60 steps per minute. Used for funerals only.

Prepatory Command: Indicates a movement is to be made. Ex: PRESENT, arms

Execution Command: The command that causes the desired movement to be executed. Ex: present, ARMS

Combined Command: The prepatory and execution commands are combined. Ex: FALL IN

Supplementary Command: Commands that cause the component units to act individually. Ex: (Column of files): FORWARD, STAND FAST, MARCH

Command Voice: Cadence, Loudness, Inflection, Clarity (CLIC)

You will need to know this for the c/SN Advancement Exam!
      ''',
    ),
    LearnSection(
      title: 'Ranks, Paygrades, and Insignia',
      icon: Icons.military_tech,
      difficulty: 'Intermediate',
      content: '''
🎖️ RANKS, PAYGRADES, AND INSIGNIA
(Source: Cadet Reference Manual, Pages 29-35)

📋 NJROTC CADET RANKS
┌─────────┬─────────────────────────────────┬─────────────────────────────────────────────┐
│Paygrade │ NJROTC Rank                     │ Insignia Description                        │
├─────────┼─────────────────────────────────┼─────────────────────────────────────────────┤
│ C/SR    │ Cadet Seaman Recruit            │ No insignia                                 │
│ C/SA    │ Cadet Seaman Apprentice         │ Two connected diagonal stripes              │
│ C/SN    │ Cadet Seaman                    │ Three connected diagonal stripes            │
│ C/PO3   │ Cadet Petty Officer Third Class │ An eagle perched atop one chevron          │
│ C/PO2   │ Cadet Petty Officer Second Class│ An eagle perched atop two chevrons         │
│ C/PO1   │ Cadet Petty Officer First Class │ An eagle perched atop three chevrons       │
│ C/CPO   │ Cadet Chief Petty Officer       │ An eagle perched atop a gold fouled anchor │
│ C/SCPO  │ Cadet Senior Chief Petty Officer│ An eagle perched atop a gold fouled        │
│         │                                 │ anchor with a star                          │
│ C/MCPO  │ Cadet Master Chief Petty Officer│ An eagle perched atop a gold fouled        │
│         │                                 │ anchor with two stars                       │
└─────────┴─────────────────────────────────┴─────────────────────────────────────────────┘

⚓ NAVY ENLISTED RANKS
┌─────────┬─────────────────────────────────┬─────────────────────────────────────────────┐
│Paygrade │ Navy Rank                       │ Insignia Description                        │
├─────────┼─────────────────────────────────┼─────────────────────────────────────────────┤
│ E-1     │ Seaman Recruit (SR)             │ No insignia                                 │
│ E-2     │ Seaman Apprentice (SA)          │ Two diagonal stripes                        │
│ E-3     │ Seaman (SN)                     │ Three diagonal stripes                      │
│ E-4     │ Petty Officer Third Class (PO3) │ An eagle perched atop one chevron          │
│ E-5     │ Petty Officer Second Class (PO2)│ An eagle perched atop two chevrons         │
│ E-6     │ Petty Officer First Class (PO1) │ An eagle perched atop three chevrons       │
│ E-7     │ Chief Petty Officer (CPO)       │ A gold fouled anchor with USN              │
│ E-8     │ Senior Chief Petty Officer(SCPO)│ A gold fouled anchor with USN and a star   │
│ E-9     │ Master Chief Petty Officer(MCPO)│ A gold fouled anchor with USN and two      │
│         │                                 │ stars                                       │
│ E-9     │ Master Chief Petty Officer of   │ A gold fouled anchor with USN and three    │
│         │ the Navy (MCPON)                │ stars                                       │
└─────────┴─────────────────────────────────┴─────────────────────────────────────────────┘

🦅 NAVY OFFICER RANKS
┌─────────┬─────────────────────────────────┬─────────────────────────────────────────────┐
│Paygrade │ Navy Rank                       │ Insignia Description                        │
├─────────┼─────────────────────────────────┼─────────────────────────────────────────────┤
│ O-1     │ Ensign (ENS)                    │ One gold bar                               │
│ O-2     │ Lieutenant Junior Grade (LTJG)  │ One silver bar                             │
│ O-3     │ Lieutenant (LT)                 │ Two silver bars                            │
│ O-4     │ Lieutenant Commander (LCDR)     │ Gold oak leaf                              │
│ O-5     │ Commander (CDR)                 │ Silver oak leaf                            │
│ O-6     │ Captain (CAPT)                  │ Silver eagle                               │
│ O-7     │ Rear Admiral (Lower Half) (RADM)│ One star                                   │
│ O-8     │ Rear Admiral (RADM)             │ Two stars                                  │
│ O-9     │ Vice Admiral (VADM)             │ Three stars                                │
│ O-10    │ Admiral (ADM)                   │ Four stars                                 │
│ O-11    │ Fleet Admiral (FADM)            │ Five stars (wartime only)                  │
└─────────┴─────────────────────────────────┴─────────────────────────────────────────────┘

🪖 MARINE CORPS ENLISTED RANKS
┌─────────┬─────────────────────────────────┬─────────────────────────────────────────────┐
│Paygrade │ Marine Corps Rank               │ Insignia Description                        │
├─────────┼─────────────────────────────────┼─────────────────────────────────────────────┤
│ E-1     │ Private (Pvt)                   │ No insignia                                 │
│ E-2     │ Private First Class (PFC)       │ One chevron                                 │
│ E-3     │ Lance Corporal (LCpl)           │ One chevron with a pair of crossed rifles  │
│ E-4     │ Corporal (Cpl)                  │ Two chevrons with a pair of crossed rifles │
│ E-5     │ Sergeant (Sgt)                  │ Three chevrons with a pair of crossed      │
│         │                                 │ rifles                                      │
│ E-6     │ Staff Sergeant (SSgt)           │ Three chevrons with a rocker and a pair    │
│         │                                 │ of crossed rifles                          │
│ E-7     │ Gunnery Sergeant (GySgt)        │ Three chevrons with two rockers and a      │
│         │                                 │ pair of crossed rifles                     │
│ E-8     │ Master Sergeant (MSgt)          │ Three chevrons with three rockers and a    │
│         │                                 │ pair of crossed rifles                     │
│ E-8     │ First Sergeant (FSgt)           │ Three chevrons with three rockers and a    │
│         │                                 │ diamond                                     │
│ E-9     │ Master Gunnery Sergeant (MGySgt)│ Three chevrons with four rockers and an    │
│         │                                 │ exploding bomb                              │
│ E-9     │ Sergeant Major (SgtMaj)         │ Three chevrons with four rockers and a     │
│         │                                 │ star                                        │
└─────────┴─────────────────────────────────┴─────────────────────────────────────────────┘

🦅 MARINE CORPS OFFICER RANKS
┌─────────┬─────────────────────────────────┬─────────────────────────────────────────────┐
│Paygrade │ Marine Corps Rank               │ Insignia Description                        │
├─────────┼─────────────────────────────────┼─────────────────────────────────────────────┤
│ O-1     │ Second Lieutenant (2ndLt)       │ One gold bar                               │
│ O-2     │ First Lieutenant (1stLt)        │ One silver bar                             │
│ O-3     │ Captain (Capt)                  │ Two silver bars                            │
│ O-4     │ Major (Maj)                     │ Gold oak leaf                              │
│ O-5     │ Lieutenant Colonel (LtCol)      │ Silver oak leaf                            │
│ O-6     │ Colonel (Col)                   │ Silver eagle                               │
│ O-7     │ Brigadier General (BGen)        │ One star                                   │
│ O-8     │ Major General (MajGen)          │ Two stars                                  │
│ O-9     │ Lieutenant General (LtGen)      │ Three stars                                │
│ O-10    │ General (Gen)                   │ Four stars                                 │
└─────────┴─────────────────────────────────┴─────────────────────────────────────────────┘

*You will need to know this for the c/SN Advancement Exam!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
    LearnSection(
      title: 'Coming Soon',
      icon: Icons.schedule,
      difficulty: 'Info',
      content: '''
🚧 Under Construction

This section is currently being developed and will be available in a future update.

Stay tuned for more comprehensive NJROTC learning materials!

📚 What's Coming:
• Additional naval knowledge modules
• Interactive study guides
• Practice quizzes and assessments
• Enhanced multimedia content

⚓ Fair winds and following seas!
      ''',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Basic Knowledge':
        return Colors.green;
      case 'Beginner':
        return Colors.blue;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Intro':
        return Icons.info_outline;
      case 'Basic Knowledge':
        return Icons.school;
      case 'Beginner':
        return Icons.star_border;
      case 'Intermediate':
        return Icons.star_half;
      case 'Advanced':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildRanksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.7,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: '🎖️ RANKS, PAYGRADES, AND INSIGNIA\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '(Source: Cadet Reference Manual, Pages 29-35)\n\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _buildRankTable(
          '📋 NJROTC CADET RANKS',
          [
            ['E-1', 'Cadet Seaman Recruit (c/SR)', 'No insignia'],
            ['E-2', 'Cadet Seaman Apprentice (c/SA)', 'Two connected diagonal stripes'],
            ['E-3', 'Cadet Seaman (c/SN)', 'Three connected diagonal stripes'],
            ['E-4', 'Cadet Petty Officer Third Class (c/PO3)', 'An eagle perched atop one chevron'],
            ['E-5', 'Cadet Petty Officer Second Class (c/PO2)', 'An eagle perched atop two chevrons'],
            ['E-6', 'Cadet Petty Officer First Class (c/PO1)', 'An eagle perched atop three chevrons'],
            ['E-7', 'Cadet Chief Petty Officer (c/CPO)', 'An eagle perched atop a gold fouled anchor'],
            ['E-8', 'Cadet Senior Chief Petty Officer (c/SCPO)', 'An eagle perched atop a gold fouled anchor with a star'],
            ['E-9', 'Cadet Master Chief Petty Officer (c/MCPO)', 'An eagle perched atop a gold fouled anchor with two stars'],
          ],
        ),
        const SizedBox(height: 20),
        _buildRankTable(
          '📋 NJROTC CADET OFFICER RANKS',
          [
            ['O-1', 'Cadet Ensign', 'One gold bar'],
            ['O-2', 'Cadet Lieutenant Junior Grade', 'Two connected gold bars'],
            ['O-3', 'Cadet Lieutenant', 'Three connected gold bars'],
            ['O-4', 'Cadet Lieutenant Commander', 'Four connected gold bars'],
            ['O-5', 'Cadet Commander', 'Five connected gold bars'],
            ['O-6', 'Cadet Captain', 'Six connected gold bars'],
          ],
        ),
        const SizedBox(height: 20),
        _buildRankTable(
          '⚓ NAVY ENLISTED RANKS',
          [
            ['E-1', 'Seaman Recruit (SR)', 'No insignia'],
            ['E-2', 'Seaman Apprentice (SA)', 'Two diagonal stripes'],
            ['E-3', 'Seaman (SN)', 'Three diagonal stripes'],
            ['E-4', 'Petty Officer Third Class (PO3)', 'An eagle perched atop one chevron'],
            ['E-5', 'Petty Officer Second Class (PO2)', 'An eagle perched atop two chevrons'],
            ['E-6', 'Petty Officer First Class (PO1)', 'An eagle perched atop three chevrons'],
            ['E-7', 'Chief Petty Officer (CPO)', 'A gold fouled anchor with USN'],
            ['E-8', 'Senior Chief Petty Officer (SCPO)', 'A gold fouled anchor with USN and a star'],
            ['E-9', 'Master Chief Petty Officer (MCPO)', 'A gold fouled anchor with USN and two stars'],
            ['E-9', 'Master Chief Petty Officer of the Navy (MCPON)', 'A gold fouled anchor with USN and three stars'],
          ],
        ),
        const SizedBox(height: 20),
        _buildRankTable(
          '🦅 NAVY OFFICER RANKS',
          [
            ['O-1', 'Ensign (ENS)', 'One gold bar'],
            ['O-2', 'Lieutenant Junior Grade (LTJG)', 'One silver bar'],
            ['O-3', 'Lieutenant (LT)', 'Two silver bars'],
            ['O-4', 'Lieutenant Commander (LCDR)', 'Gold oak leaf'],
            ['O-5', 'Commander (CDR)', 'Silver oak leaf'],
            ['O-6', 'Captain (CAPT)', 'Silver eagle'],
            ['O-7', 'Rear Admiral (Lower Half) (RADM)', 'One star'],
            ['O-8', 'Rear Admiral (RADM)', 'Two stars'],
            ['O-9', 'Vice Admiral (VADM)', 'Three stars'],
            ['O-10', 'Admiral (ADM)', 'Four stars'],
            ['O-11', 'Fleet Admiral (FADM)', 'Five stars (wartime only)'],
          ],
        ),
        const SizedBox(height: 20),
        _buildRankTable(
          '🪖 MARINE CORPS ENLISTED RANKS',
          [
            ['E-1', 'Private (Pvt)', 'No insignia'],
            ['E-2', 'Private First Class (PFC)', 'One chevron'],
            ['E-3', 'Lance Corporal (LCpl)', 'One chevron with a pair of crossed rifles'],
            ['E-4', 'Corporal (Cpl)', 'Two chevrons with a pair of crossed rifles'],
            ['E-5', 'Sergeant (Sgt)', 'Three chevrons with a pair of crossed rifles'],
            ['E-6', 'Staff Sergeant (SSgt)', 'Three chevrons with a rocker and a pair of crossed rifles'],
            ['E-7', 'Gunnery Sergeant (GySgt)', 'Three chevrons with two rockers and a pair of crossed rifles'],
            ['E-8', 'Master Sergeant (MSgt)', 'Three chevrons with three rockers and a pair of crossed rifles'],
            ['E-8', 'First Sergeant (FSgt)', 'Three chevrons with three rockers and a diamond'],
            ['E-9', 'Master Gunnery Sergeant (MGySgt)', 'Three chevrons with four rockers and an exploding bomb'],
            ['E-9', 'Sergeant Major (SgtMaj)', 'Three chevrons with four rockers and a star'],
          ],
        ),
        const SizedBox(height: 20),
        _buildRankTable(
          '🦅 MARINE CORPS OFFICER RANKS',
          [
            ['O-1', 'Second Lieutenant (2ndLt)', 'One gold bar'],
            ['O-2', 'First Lieutenant (1stLt)', 'One silver bar'],
            ['O-3', 'Captain (Capt)', 'Two silver bars'],
            ['O-4', 'Major (Maj)', 'Gold oak leaf'],
            ['O-5', 'Lieutenant Colonel (LtCol)', 'Silver oak leaf'],
            ['O-6', 'Colonel (Col)', 'Silver eagle'],
            ['O-7', 'Brigadier General (BGen)', 'One star'],
            ['O-8', 'Major General (MajGen)', 'Two stars'],
            ['O-9', 'Lieutenant General (LtGen)', 'Three stars'],
            ['O-10', 'General (Gen)', 'Four stars'],
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '*You will need to know this for the c/SN Advancement Exam!',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledContent(String content) {
    List<TextSpan> spans = [];
    String remainingText = content;
    
    // Define patterns for bold formatting
    final boldPatterns = [
      // Emojis with titles
      RegExp(r'📚 About This Learning Material'),
      RegExp(r'📖 Source Materials'),
      RegExp(r'🎯 Learning Objectives'),
      RegExp(r'⚓ Study Tips'),
      // Section headers with emojis
      RegExp(r'🎖️ The Eleven General Orders of the Sentry'),
      RegExp(r'⚔️ Chain of Command'),
      RegExp(r'📋 PERSONAL APPEARANCE AND GROOMING'),
      RegExp('👨 Men\'s Grooming Standards'),
      RegExp('👩 Women\'s Grooming Standards'),
      RegExp(r'📝 NOTE:'),
      RegExp(r'📐 DRILL TERMINOLOGY'),
      RegExp(r'🎯 Essential Drill Terms'),
      // Source references
      RegExp(r'\(Source: [^)]+\)'),
      // Key vocabulary terms at start of definitions
      RegExp(r'^Hair:', multiLine: true),
      RegExp(r'^Sideburns:', multiLine: true),
      RegExp(r'^Mustaches:', multiLine: true),
      RegExp(r'^Fingernails:', multiLine: true),
      RegExp(r'^Earrings/Studs:', multiLine: true),
      RegExp(r'^Necklaces:', multiLine: true),
      RegExp(r'^Rings:', multiLine: true),
      RegExp(r'^Wristwatch/Bracelet:', multiLine: true),
      RegExp(r'^Sunglasses:', multiLine: true),
      RegExp(r'^Hair Length:', multiLine: true),
      RegExp(r'^Hair Bulk:', multiLine: true),
      RegExp(r'^Hair Color:', multiLine: true),
      RegExp(r'^Ponytails:', multiLine: true),
      RegExp(r'^Hair Accessories:', multiLine: true),
      RegExp(r'^Hair Ornaments:', multiLine: true),
      RegExp(r'^Cosmetics:', multiLine: true),
      RegExp(r'^Alignment:', multiLine: true),
      RegExp(r'^Cadence:', multiLine: true),
      RegExp(r'^Column:', multiLine: true),
      RegExp(r'^Depth:', multiLine: true),
      RegExp(r'^Distance:', multiLine: true),
      RegExp(r'^Double Time:', multiLine: true),
      RegExp(r'^File:', multiLine: true),
      RegExp(r'^Front:', multiLine: true),
      RegExp(r'^Inflection:', multiLine: true),
      RegExp(r'^Pace:', multiLine: true),
      RegExp(r'^Quick Time:', multiLine: true),
      RegExp(r'^Rank:', multiLine: true),
      RegExp(r'^Slow Time:', multiLine: true),
      RegExp(r'^Prepatory Command:', multiLine: true),
      RegExp(r'^Execution Command:', multiLine: true),
      RegExp(r'^Combined Command:', multiLine: true),
      RegExp(r'^Supplementary Command:', multiLine: true),
      RegExp(r'^Command Voice:', multiLine: true),
      // Key concepts in definitions
      RegExp(r'THe rise and fall in pitch with plenty of snap'),
      RegExp(r'Cadence, Loudness, Inflection, Clarity \(CLIC\)'),
    ];
    
    while (remainingText.isNotEmpty) {
      int earliestMatch = remainingText.length;
      RegExp? matchedPattern;
      Match? foundMatch;
      
      // Find the earliest bold pattern match
      for (final pattern in boldPatterns) {
        final match = pattern.firstMatch(remainingText);
        if (match != null && match.start < earliestMatch) {
          earliestMatch = match.start;
          matchedPattern = pattern;
          foundMatch = match;
        }
      }
      
      if (foundMatch != null && matchedPattern != null) {
        // Add text before the match as regular text
        if (foundMatch.start > 0) {
          spans.add(TextSpan(text: remainingText.substring(0, foundMatch.start)));
        }
        
        // Add the matched text as bold
        spans.add(TextSpan(
          text: foundMatch.group(0)!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        
        // Update remaining text
        remainingText = remainingText.substring(foundMatch.end);
      } else {
        break;
      }
    }
    
    // Add any remaining text
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(text: remainingText));
    }
    
    // Check for italic phrase and add it
    if (content.contains('You will need to know this for')) {
      // Find and replace the italic phrase in the spans
      for (int i = 0; i < spans.length; i++) {
        final spanText = spans[i].text ?? '';
        if (spanText.contains('You will need to know this for')) {
          final parts = spanText.split('You will need to know this for');
          final List<TextSpan> newSpans = [];
          
          if (parts[0].isNotEmpty) {
            newSpans.add(TextSpan(
              text: parts[0],
              style: spans[i].style,
            ));
          }
          
          newSpans.add(TextSpan(
            text: 'You will need to know this for${parts.length > 1 ? parts[1] : ''}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ));
          
          spans.replaceRange(i, i + 1, newSpans);
          break;
        }
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildRankTable(String title, List<List<String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.navyBlue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.all(
              color: AppColors.navyBlue.withOpacity(0.2),
              width: 0.5,
            ),
            columnWidths: const {
              0: FixedColumnWidth(100),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.navyBlue.withOpacity(0.1),
                ),
                children: const [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.navyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.navyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Insignia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.navyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...data.map((row) => TableRow(
                children: row.map((cell) => TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      cell,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      textAlign: row.indexOf(cell) == 0 
                          ? TextAlign.center 
                          : TextAlign.left,
                    ),
                  ),
                )).toList(),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Back to Dashboard',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightGray.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced header section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Welcome message
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.navyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.waves,
                          color: AppColors.navyBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Aboard!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            Text(
                              'Master the curriculum with this comprehensive guide',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Page indicator with enhanced styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navyBlue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: AppColors.navyBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Section ${_currentPage + 1} of ${_sections.length}',
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ...List.generate(
                          _sections.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? AppColors.navyBlue
                                  : AppColors.navyBlue.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Enhanced section icon and title
                        Hero(
                          tag: 'section_$index',
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.navyBlue,
                                  AppColors.primaryBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navyBlue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              section.icon,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(section.difficulty).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getDifficultyColor(section.difficulty),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getDifficultyIcon(section.difficulty),
                                size: 16,
                                color: _getDifficultyColor(section.difficulty),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                section.difficulty,
                                style: TextStyle(
                                  color: _getDifficultyColor(section.difficulty),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Enhanced content container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.navyBlue.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: section.title == 'Ranks, Paygrades, and Insignia'
                              ? _buildRanksSection()
                              : _buildStyledContent(section.content),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Enhanced navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage > 0 
                          ? AppColors.lightBlue 
                          : Colors.grey[300],
                      foregroundColor: _currentPage > 0 
                          ? Colors.white 
                          : Colors.grey[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: _currentPage > 0 ? 3 : 0,
                    ),
                  ),
                  // Section indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _sections[_currentPage].icon,
                          size: 16,
                          color: AppColors.navyBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentPage + 1}/${_sections.length}',
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Next button
                  ElevatedButton.icon(
                    onPressed: _currentPage < _sections.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    label: const Text('Next'),
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage < _sections.length - 1 
                          ? AppColors.navyBlue 
                          : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearnSection {
  final String title;
  final IconData icon;
  final String content;
  final String difficulty;

  LearnSection({
    required this.title,
    required this.icon,
    required this.content,
    required this.difficulty,
  });
}
